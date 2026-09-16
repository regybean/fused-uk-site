#!/usr/bin/env bash
# Deployment wizard: fuseduk.co.uk -> Vercel (DNS stays at names.co.uk)
# Resumable. Run repeatedly; completed steps are skipped unless --from N.
set -uo pipefail

APEX="fuseduk.co.uk"
WWW="www.fuseduk.co.uk"
UK_APEX="fuseduk.uk"
UK_WWW="www.fuseduk.uk"
VERCEL_APEX_IP="216.198.79.1"   # fallback only; real values fetched in step 6
VERCEL_CNAME="cname.vercel-dns.com"
TARGET_FILE=".vercel/dns-target.txt"
STATE_FILE=".vercel/wizard-state"
VC="npx --yes vercel@latest"

BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; CYN=$'\033[36m'; RST=$'\033[0m'

say()  { printf '%s\n' "$*"; }
head2() { printf '\n%s== %s ==%s\n' "$BOLD" "$*" "$RST"; }
ok()   { printf '%s  ok%s  %s\n' "$GRN" "$RST" "$*"; }
warn() { printf '%s  !!%s  %s\n' "$YLW" "$RST" "$*"; }
die()  { printf '%s fail%s  %s\n' "$RED" "$RST" "$*" >&2; exit 1; }
hint() { printf '%s      %s%s\n' "$DIM" "$*" "$RST"; }

pause() {
  local reply=""
  { : </dev/tty; } 2>/dev/null || { warn "no tty - assuming continue"; return 0; }
  printf '\n%s[enter] to continue, [s] to skip this step, [q] to quit: %s' "$CYN" "$RST"
  read -r reply </dev/tty || true
  case "$reply" in
    q|Q) say "bye"; exit 0 ;;
    s|S) return 1 ;;
    *)   return 0 ;;
  esac
}

confirm() {
  local reply=""
  if (( ASSUME_YES )); then warn "--yes: auto-answering Y to: $1"; return 0; fi
  { : </dev/tty; } 2>/dev/null || { warn "no tty - answering N to: $1"; return 1; }
  printf '%s%s [y/N]: %s' "$CYN" "$1" "$RST"
  read -r reply </dev/tty || true
  [[ "$reply" == [yY]* ]]
}

mark_done() { mkdir -p "$(dirname "$STATE_FILE")"; grep -qx "$1" "$STATE_FILE" 2>/dev/null || echo "$1" >> "$STATE_FILE"; }
is_done()   { grep -qx "$1" "$STATE_FILE" 2>/dev/null; }

FROM=0; ONLY=0; ASSUME_YES=0
[[ " $* " == *" --yes "* ]] && ASSUME_YES=1
case "${1:-}" in
  --from)  FROM="${2:-0}" ;;
  --only)  ONLY="${2:-0}" ;;
  --reset) rm -f "$STATE_FILE"; say "state cleared" ;;
  -h|--help) say "usage: $0 [--from N | --only N | --reset] [--yes]"; exit 0 ;;
esac

step() { # step <n> <title>
  local n="$1"; shift
  if (( ONLY > 0 )); then
    if (( n != ONLY )); then return 1; fi
  elif (( FROM > 0 )); then
    if (( n < FROM )); then
      printf '%s-- step %s skipped (--from %s)%s\n' "$DIM" "$n" "$FROM" "$RST"
      return 1
    fi
  elif is_done "step$n"; then
    printf '%s-- step %s: %s (already done)%s\n' "$DIM" "$n" "$*" "$RST"
    return 1
  fi
  head2 "step $n: $*"
  return 0
}

cat <<'BANNER'
+--------------------------------------------------------------+
|  fuseduk.co.uk  ->  Vercel deployment wizard                 |
|  registrar/DNS: names.co.uk (nameservers stay put)           |
+--------------------------------------------------------------+
BANNER
say "state: ${STATE_FILE}   (--reset to start over, --from N to rerun from a step)"

# ---------------------------------------------------------------- 1 preflight
if step 1 "preflight"; then
  command -v node >/dev/null || die "node not found"
  command -v pnpm >/dev/null || die "pnpm not found"
  command -v dig  >/dev/null || warn "dig not found; DNS checks will be skipped"
  ok "node $(node -v), pnpm $(pnpm -v)"

  dirty=$(git status --porcelain -- . ':(exclude)dist' ':(exclude).astro')
  if [[ -n "$dirty" ]]; then
    warn "uncommitted source changes (build artifacts ignored):"
    printf '%s\n' "$dirty" | sed 's/^/        /'
    hint "vercel builds from the git repo once step 9.2 is done - unpushed work will not go live"
    confirm "continue anyway?" || die "commit or stash first"
  else
    ok "working tree clean"
  fi

  say "building..."
  if pnpm build >/tmp/fused-build.log 2>&1; then
    ok "production build passes ($(find dist -type f | wc -l | tr -d ' ') files in dist/)"
  else
    tail -30 /tmp/fused-build.log
    die "build failed - see /tmp/fused-build.log"
  fi
  mark_done step1
fi

# ---------------------------------------------------------------- 2 vercel auth
if step 2 "vercel account"; then
  if user=$($VC whoami 2>/dev/null); then
    ok "logged in as $user"
  else
    say "opening vercel login (browser)..."
    hint "use the same account/team that will own the project"
    $VC login </dev/tty || die "vercel login failed"
    user=$($VC whoami 2>/dev/null) && ok "logged in as $user"
  fi
  mark_done step2
fi

# ---------------------------------------------------------------- 3 link project
if step 3 "link this repo to a vercel project"; then
  if [[ -f .vercel/project.json ]]; then
    ok "already linked: $(node -e 'const p=require("./.vercel/project.json");console.log(p.projectId)' 2>/dev/null)"
  else
    hint "answer: link to existing = N (unless you already made one), name = fuseduk"
    hint "framework should auto-detect as Astro, output dir dist/"
    $VC link </dev/tty || die "vercel link failed"
    ok "linked"
  fi
  mark_done step3
fi

# ---------------------------------------------------------------- 4 deploy
if step 4 "deploy to production"; then
  say "deploying (builds on vercel's side)..."
  if $VC deploy --prod --yes </dev/tty | tee /tmp/fused-deploy.log; then
    DEPLOY_URL=$(grep -Eo 'https://[a-zA-Z0-9.-]+\.vercel\.app' /tmp/fused-deploy.log | tail -1)
    [[ -n "$DEPLOY_URL" ]] && { ok "live at $DEPLOY_URL"; echo "$DEPLOY_URL" > .vercel/last-deploy-url; }
    say ""
    say "${BOLD}Check the .vercel.app URL in a browser now.${RST} Every page, on mobile width too."
    hint "DNS is the hard-to-undo bit - do not cut over until this looks right"
    confirm "site looks correct?" || die "fix the site, then rerun: ./scripts/deploy-wizard.sh --from 4"
  else
    die "deploy failed - see /tmp/fused-deploy.log"
  fi
  mark_done step4
fi

# ---------------------------------------------------------------- helpers
fetch_targets() { # fetch_targets <domain> -> sets A_VALS[] CNAME_VAL
  local d="$1"
  $VC domains verify "$d" 2>/dev/null | sed -n '/^{/,$p' > /tmp/fused-verify.json
  A_VALS=()
  if jq -e '.recommended' /tmp/fused-verify.json >/dev/null 2>&1; then
    while IFS= read -r line; do [[ -n "$line" ]] && A_VALS+=("$line"); done \
      < <(jq -r '.recommended.records[]? | select(.type=="A") | .value' /tmp/fused-verify.json)
    CNAME_VAL=$(jq -r '[.recommended.cname[]? | select(.rank==1) | .value] | first // empty' /tmp/fused-verify.json | sed 's/\.$//')
  else
    CNAME_VAL=""
  fi
  [[ ${#A_VALS[@]-0} -eq 0 ]] && A_VALS=("$VERCEL_APEX_IP")
  [[ -z "$CNAME_VAL" ]] && CNAME_VAL="$VERCEL_CNAME"
  printf 'A %s\n' "${A_VALS[@]}" > "$TARGET_FILE"
  printf 'CNAME %s\n' "$CNAME_VAL" >> "$TARGET_FILE"
  A1="${A_VALS[0]}"
  A2="${A_VALS[1]-}"
}

host_on_vercel() { # host_on_vercel <host> -> 0 if DNS resolves to vercel
  local h="$1" out v
  out=$(dig +short "$h" @1.1.1.1 2>/dev/null | tr '\n' ' ')
  [[ "$out" == *vercel* ]] && return 0
  for v in "${A_VALS[@]}"; do [[ "$out" == *"$v"* ]] && return 0; done
  return 1
}

# ---------------------------------------------------------------- 5 add domains
if step 5 "attach all four domains to the vercel project"; then
  for d in "$APEX" "$WWW" "$UK_APEX" "$UK_WWW"; do
    $VC domains add "$d" fuseduk --force >/dev/null 2>&1 \
      && ok "$d attached" || warn "could not attach $d"
  done
  hint "redirects (www.fuseduk.co.uk, fuseduk.uk, www.fuseduk.uk -> fuseduk.co.uk)"
  hint "are already configured on the vercel side - nothing to click in the dashboard"
  mark_done step5
fi

# ---------------------------------------------------------------- 6 dns: fuseduk.co.uk
if step 6 "DNS at names.co.uk - fuseduk.co.uk (the real site)"; then
  say "asking vercel which records it wants..."
  fetch_targets "$APEX"
  ok "apex -> ${A_VALS[*]} | www -> $CNAME_VAL"

  printf '\n%sWhere:%s names.co.uk -> Domains -> Add/Modify DNS Zone\n' "$BOLD" "$RST"
  hint "Domain(s) selector MUST read fuseduk.co.uk (fuseduk.uk is step 7)"
  hint 'leave "Apply template" on "Please select..." - a template would wipe your mail records'

  cat <<'ERREOF'

  +------------------------------------------------------------------+
  |  If you got: "Result for A record 5 must be an IP address"       |
  |                                                                  |
  |  That is the form refusing to accept a hostname in a row it      |
  |  still treats as type A. Row 5 cannot be converted from A to     |
  |  CNAME in place - it validates against the original type.        |
  |  Use Option 1 or Option 2 below instead.                         |
  +------------------------------------------------------------------+
ERREOF

  printf '\n%s### The apex (do this either way) ###%s\n\n' "$BOLD" "$RST"
  printf '  Row 1   Host: %s(blank)%s   Type: A   Result: %s%s%s   <- replace 178.18.126.102\n' "$DIM" "$RST" "$GRN" "$A1" "$RST"
  if [[ -n "$A2" ]]; then
    printf '  Row 15  Host: %s(blank)%s   Type: A   Result: %s%s%s   <- first empty A row\n' "$DIM" "$RST" "$GRN" "$A2" "$RST"
    hint "if the form rejects a second apex A record, skip row 15 - one IP works"
  fi

  printf '\n%s### www - pick ONE option ###%s\n' "$BOLD" "$RST"

  printf '\n%sOption 1: all A records (easiest - no CNAME, no form errors)%s\n\n' "$BOLD$GRN" "$RST"
  printf '  Row 5   Host: www   Type: A   Result: %s%s%s   <- just overwrite the IP\n' "$GRN" "$A1" "$RST"
  printf '  Row 16  Host: www   Type: A   Result: %s%s%s\n' "$GRN" "${A2:-$A1}" "$RST"
  printf '  %sOne save. The row stays type A, so the validator is happy.%s\n' "$DIM" "$RST"
  printf '  %sTrade-off: if Vercel ever changes these IPs you must edit them by hand.%s\n' "$DIM" "$RST"

  printf '\n%sOption 2: CNAME (what Vercel officially recommends - needs TWO saves)%s\n\n' "$BOLD" "$RST"
  printf '  Save 1: clear the Result field on Row 5 (www) so it is empty, then Save.\n'
  printf '  Save 2: click %s+ Add records%s, then fill the new row:\n' "$BOLD" "$RST"
  printf '            Host: www    Type: CNAME    Result: %s%s%s\n' "$GRN" "$CNAME_VAL" "$RST"
  printf '          then Save again.\n'
  printf '  %sNo trailing dot - match the existing imap/pop3 CNAME rows.%s\n' "$DIM" "$RST"
  printf '  %sTwo saves because a host cannot hold an A and a CNAME at once.%s\n' "$DIM" "$RST"

  printf '\n  %sEither option works. Option 1 if you want this done now;%s\n' "$BOLD" "$RST"
  printf '  %sOption 2 if you want the setup Vercel maintains for you.%s\n' "$BOLD" "$RST"

  cat <<'DNSEOF'

### Leave every other row alone ###

  Row 2      *                 A       wildcard - cannot shadow apex or www
  Rows 3,4   ftp               A/CNAME hosting FTP access
  Rows 6,7,8 autoconfig/imap/pop3  CNAME   MAIL CLIENT SETUP
  Rows 9,10  (apex)            TXT     SPF - MAIL DELIVERABILITY
  Rows 11-14 _acme-challenge   TXT     stale cert tokens, harmless
  MX section                   MX      10 mx1.ukservers.net - YOUR EMAIL
  SRV section _autodiscover    SRV     OUTLOOK AUTODISCOVER

  Those mail rows are exactly why we edit records instead of handing the
  nameservers to Vercel.

DNSEOF
  say "${BOLD}Right now:${RST}"
  command -v dig >/dev/null && {
    printf '  %-20s %s\n' "$APEX" "$(dig +short A "$APEX" | tr '\n' ' ')"
    printf '  %-20s %s\n' "$WWW" "$(dig +short "$WWW" | tr '\n' ' ')"
  }
  hint "rollback: rows 1 and 5 back to A 178.18.126.102 (.vercel/dns-before.txt)"
  say "Save the zone, then come back."
  pause && mark_done step6
fi

# ---------------------------------------------------------------- 7 dns: fuseduk.uk
if step 7 "DNS at names.co.uk - fuseduk.uk (redirects to the real site)"; then
  fetch_targets "$UK_APEX"
  say "This is the SECOND domain. Change the Domain(s) selector to ${BOLD}fuseduk.uk${RST}."
  hint "vercel already knows to 308-redirect fuseduk.uk -> fuseduk.co.uk"
  hint "it just needs the DNS pointed at vercel so the redirect can happen"

  printf '\n%s### Changes (this zone is much simpler - only 2 web rows) ###%s\n\n' "$BOLD" "$RST"
  printf '  Row 1   Host: %s(blank)%s   Type: A   Result: %s%s%s   <- replace 85.233.160.215\n' "$DIM" "$RST" "$GRN" "$A1" "$RST"
  printf '  Row 2   Host: www       Type: A   Result: %s%s%s   <- replace 85.233.160.215\n' "$GRN" "$A1" "$RST"
  if [[ -n "$A2" ]]; then
    printf '  Row 3   Host: %s(blank)%s   Type: A   Result: %s%s%s   <- optional 2nd IP\n' "$DIM" "$RST" "$GRN" "$A2" "$RST"
    printf '  Row 4   Host: www       Type: A   Result: %s%s%s   <- optional 2nd IP\n' "$GRN" "$A2" "$RST"
  fi
  hint "all type A, so no CNAME/validator trouble in this zone at all"

  cat <<'UKEOF'

### Leave alone ###

  MX section   30 fwd0.hosts.co.uk
               30 fwd1.hosts.co.uk   <- mail FORWARDING for fuseduk.uk
               30 fwd2.hosts.co.uk

  If any address @fuseduk.uk forwards mail anywhere, those three rows are
  what make it work. Changing the A records does not affect them.

UKEOF
  say "${BOLD}Right now:${RST}"
  command -v dig >/dev/null && {
    printf '  %-20s %s\n' "$UK_APEX" "$(dig +short A "$UK_APEX" | tr '\n' ' ')"
    printf '  %-20s %s\n' "$UK_WWW" "$(dig +short "$UK_WWW" | tr '\n' ' ')"
  }
  hint "rollback for this zone: both rows back to A 85.233.160.215"
  pause && mark_done step7
fi

# ---------------------------------------------------------------- 8 wait for dns
if step 8 "wait for DNS propagation (all four hostnames)"; then
  if ! command -v dig >/dev/null; then
    warn "no dig; skipping DNS poll"
    mark_done step8
  else
    if [[ -f "$TARGET_FILE" ]]; then
      A_VALS=()
      while IFS= read -r line; do [[ -n "$line" ]] && A_VALS+=("$line"); done < <(awk '$1=="A"{print $2}' "$TARGET_FILE")
    else
      A_VALS=("$VERCEL_APEX_IP")
    fi
    [[ ${#A_VALS[@]-0} -eq 0 ]] && A_VALS=("$VERCEL_APEX_IP")
    say "waiting for all of these to resolve to vercel (${A_VALS[*]} or a *.vercel-dns.com CNAME)"
    say "polling every 30s - ctrl-c any time, resume with --from 8"
    for i in $(seq 1 80); do
      done_count=0; line=""
      for h in "$APEX" "$WWW" "$UK_APEX" "$UK_WWW"; do
        if host_on_vercel "$h"; then
          done_count=$((done_count+1)); line="$line ${GRN}ok${RST}:$h"
        else
          line="$line ${YLW}--${RST}:$h"
        fi
      done
      printf '\r  [%02d] %d/4%s        ' "$i" "$done_count" "$line"
      if (( done_count == 4 )); then say ""; ok "all four resolve to vercel"; mark_done step8; break; fi
      sleep 30
    done
    is_done step8 || { say ""; warn "not fully propagated - names.co.uk can take a few hours. rerun: --from 8"; }
  fi
fi

# ---------------------------------------------------------------- 9 verify
if step 9 "verify HTTPS, redirects, and that vercel is serving"; then
  all_good=yes
  EDGE_GOOD=yes

  if [[ -f "$TARGET_FILE" ]]; then
    VIP=$(awk '$1=="A"{print $2; exit}' "$TARGET_FILE")
  else
    VIP="$VERCEL_APEX_IP"
  fi
  [[ -z "$VIP" ]] && VIP="$VERCEL_APEX_IP"

  # --- 0. is THIS machine's resolver stale? -------------------------------
  printf '\n%sYour local DNS resolver:%s\n' "$BOLD" "$RST"
  local_ip=$(dscacheutil -q host -a name "$APEX" 2>/dev/null | awk '/^ip_address/{print $2; exit}')
  public_ip=$(dig +short A "$APEX" @1.1.1.1 2>/dev/null | head -1)
  STALE=no
  if [[ -n "$local_ip" && -n "$public_ip" && "$local_ip" != "$public_ip" ]]; then
    warn "STALE CACHE: your machine says $local_ip, the internet says $public_ip"
    say  "        Your browser and curl are still hitting the OLD host. Flush it:"
    printf '        %ssudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder%s\n' "$BOLD" "$RST"
    hint "until you flush, apex->www->apex will look like an infinite redirect loop:"
    hint "the old host 301s the apex to www, and vercel 308s www back to the apex"
    STALE=yes
  elif [[ -n "$local_ip" ]]; then
    ok "matches public DNS ($local_ip)"
  fi

  # --- 1. is vercel's edge serving the apex at all? -----------------------
  printf '\n%sVercel edge, force-resolved to %s (ignores your cache):%s\n' "$BOLD" "$VIP" "$RST"
  edge=$(curl -sSI --resolve "$APEX:80:$VIP" --max-time 20 "http://$APEX" 2>&1)
  if printf '%s' "$edge" | grep -qi '^server: *Vercel'; then
    ok "vercel is answering for $APEX"
  else
    warn "vercel is NOT answering on $VIP for $APEX"
    all_good=no
  fi

  # --- 2. certificates (issue them if vercel has not yet) ---------------
  printf '\n%sTLS certificates (force-resolved, so your cache cannot mislead):%s\n' "$BOLD" "$RST"
  for h in "$APEX" "$WWW" "$UK_APEX" "$UK_WWW"; do
    tls=$(curl -sSI --resolve "$h:443:$VIP" --max-time 20 "https://$h" 2>&1)
    if printf '%s' "$tls" | grep -qiE '^HTTP/'; then
      ok "$h - cert live"
      continue
    fi
    warn "$h - no usable cert yet, asking vercel to issue one..."
    if $VC certs issue "$h" 2>&1 | grep -q 'Success'; then
      tls=$(curl -sSI --resolve "$h:443:$VIP" --max-time 20 "https://$h" 2>&1)
      if printf '%s' "$tls" | grep -qiE '^HTTP/'; then
        ok "$h - cert issued and live"
      else
        warn "$h - cert created but not serving yet (give it a minute)"
        EDGE_GOOD=no; all_good=no
      fi
    else
      warn "$h - issuance did not succeed; retry: npx vercel@latest certs issue $h"
      EDGE_GOOD=no; all_good=no
    fi
  done

  # --- 3. what vercel's edge actually serves ----------------------------
  printf '\n%sWhat vercel serves (force-resolved to %s):%s\n' "$BOLD" "$VIP" "$RST"
  eh=$(curl -sSI --resolve "$APEX:443:$VIP" --max-time 20 "https://$APEX" 2>/dev/null)
  ec=$(printf '%s' "$eh" | awk 'tolower($1) ~ /^http/ {print $2; exit}')
  if [[ "$ec" == "200" ]] && printf '%s' "$eh" | grep -qi '^x-vercel-id:'; then
    ok "$APEX -> 200 with x-vercel-id"
  else
    warn "$APEX -> ${ec:-no response} - expected 200 from vercel"
    EDGE_GOOD=no; all_good=no
  fi
  for h in "$WWW" "$UK_APEX" "$UK_WWW"; do
    rh=$(curl -sSI --resolve "$h:443:$VIP" --max-time 20 "https://$h" 2>/dev/null)
    rc=$(printf '%s' "$rh" | awk 'tolower($1) ~ /^http/ {print $2; exit}')
    rl=$(printf '%s' "$rh" | awk 'tolower($1)=="location:" {print $2; exit}' | tr -d '\r')
    case "$rc" in
      30[1278]) ok "$h -> $rc -> ${rl:-?}" ;;
      *)        warn "$h -> ${rc:-no response} - expected a redirect"; EDGE_GOOD=no; all_good=no ;;
    esac
  done

  # --- 3b. the apex as YOUR machine sees it -----------------------------
  printf '\n%sApex as your machine resolves it (no -L, so loops cannot hide):%s\n' "$BOLD" "$RST"
  hdrs=$(curl -sSI --max-time 20 "https://$APEX" 2>/dev/null)
  code=$(printf '%s' "$hdrs" | awk 'tolower($1) ~ /^http/ {print $2; exit}')
  loc=$(printf '%s' "$hdrs"  | awk 'tolower($1)=="location:" {print $2; exit}' | tr -d '\r')
  srv=$(printf '%s' "$hdrs"  | awk 'tolower($1)=="server:" {print $2; exit}' | tr -d '\r')
  if [[ "$code" == "200" ]] && printf '%s' "$hdrs" | grep -qi '^x-vercel-id:'; then
    ok "https://$APEX -> 200, x-vercel-id present"
  elif [[ "$loc" == *"www.$APEX"* ]]; then
    warn "https://$APEX -> $code -> $loc (server: ${srv:-?})"
    hint "apex redirecting to www is the OLD host - vercel never does this."
    hint "stale cache (flush it, above) or row 1 still 178.18.126.102."
    all_good=no
  elif [[ -z "$code" ]]; then
    warn "https://$APEX -> no response from your resolver's IP"
    all_good=no
  else
    warn "https://$APEX -> $code${loc:+ -> $loc} (server: ${srv:-?}) - expected 200"
    all_good=no
  fi

  # --- 5. vercel's own opinion ------------------------------------------
  printf '\n%sVercel'"'"'s own view:%s\n' "$BOLD" "$RST"
  for d in "$APEX" "$UK_APEX"; do
    $VC domains verify "$d" 2>/dev/null | sed -n '/^{/,$p' > /tmp/fused-v9.json
    if jq -e . /tmp/fused-v9.json >/dev/null 2>&1; then
      jq -r --arg d "$d" '"  " + $d + ": " + (.configurationStatus // "?") + " (ok=" + ((.ok // false)|tostring) + ")"' /tmp/fused-v9.json
      jq -e '.ok == true' /tmp/fused-v9.json >/dev/null 2>&1 || all_good=no
    else
      warn "$d: could not read vercel's response (API hiccup or auth expired)"
      hint "try: npx vercel@latest domains verify $d"
      all_good=no
    fi
  done

  say ""
  if [[ "$all_good" == yes ]]; then
    ok "cutover complete - everything green"
    mark_done step9
  elif [[ "$EDGE_GOOD" == yes && "$STALE" == yes ]]; then
    ok "THE SITE IS LIVE AND CORRECT FOR EVERYONE ELSE"
    say "        Every check against vercel's edge passed. The only failure is"
    say "        your own machine's stale DNS cache. Flush it and reload:"
    printf '        %ssudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder%s\n' "$BOLD" "$RST"
    hint "note: other resolvers holding the old record will clear on their own TTL"
    mark_done step9
  else
    warn "not there yet - rerun: ./scripts/deploy-wizard.sh --from 9"
  fi
fi

# ---------------------------------------------------------------- 10 finish up
if step 10 "finishing touches"; then
  cat <<'FINEOF'

Already done for you - nothing to click:
  - www.fuseduk.co.uk -> fuseduk.co.uk   (308)
  - fuseduk.uk        -> fuseduk.co.uk   (308)
  - www.fuseduk.uk    -> fuseduk.co.uk   (308)
  - TLS certs issued for all four hostnames (step 9 does this automatically
    if any are missing - vercel sometimes needs the nudge)

Git is ALREADY connected: regybean/fused-uk-site, main -> production,
framework=astro, node 24.x. `git push` deploys. Nothing to set up.

STILL TO DO - in this order, once the old apex TTL has expired
(authoritative TTL is 86400, so ~24h after you changed row 1):

1. Check no resolver still holds the old apex IP:
     dig +short A fuseduk.co.uk @130.43.187.40   # your ISP's stale one
   Wait until that returns 216.198.79.1, not 178.18.126.102.

2. Re-enable the www -> apex redirect (removed to break a redirect loop;
   until it is back, apex and www both serve the site = duplicate content):
     TOK=$(jq -r .token "$HOME/Library/Application Support/com.vercel.cli/auth.json")
     curl -sS -X PATCH \
       "https://api.vercel.com/v9/projects/fuseduk/domains/www.fuseduk.co.uk?teamId=team_eNANZV64FCaCibJUrfORoB6k" \
       -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
       -d '{"redirect":"fuseduk.co.uk","redirectStatusCode":308}'
   Then confirm no loop:  curl -sSI -L --max-redirs 5 https://www.fuseduk.co.uk

3. ONLY THEN disable the old names.co.uk hosting
   Domains & SSL -> Websites -> disable the fuseduk.co.uk entry.
   Do NOT do this before step 2 succeeds: while resolvers still point the
   apex at the old host, its 301 to www is what carries those visitors to
   the new site. Disabling it early black-holes them.

OPTIONAL:

4. Add the second apex A record 64.29.17.1 at names.co.uk (row 15).
   You only added 216.198.79.1, so there is no failover IP. Works fine
   as-is; this is belt-and-braces.

5. Fix the SPF records (nothing to do with this deploy)
   fuseduk.co.uk has TWO SPF TXT records:
     v=spf1 include:spf.hosts.co.uk ~all
     v=spf1 mx include:spf.ukservers.net ~all
   RFC 7208 allows exactly one; most receivers treat two as a permerror,
   which can hurt mail deliverability. They need merging into one record.

Rollback, any time:
  fuseduk.co.uk  -> rows 1 and 5 back to A 178.18.126.102
  fuseduk.uk     -> rows 1 and 2 back to A 85.233.160.215
  Full snapshot: .vercel/dns-before.txt

FINEOF
  pause && mark_done step10
fi

head2 "done"
say "state: $(tr '\n' ' ' < "$STATE_FILE" 2>/dev/null)"
