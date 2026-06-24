export const EMAIL = "sales@fuseduk.co.uk"
export const PHONE = "07729 577307"
export const TEL = "tel:07729577307"

export const GOOGLE_REVIEWS_URL =
  "https://www.google.com/search?sca_esv=17f1fe3018333faf&q=fuseduk&si=APenkKn5T4YN59srr511wD6k6Pufj9DEzRUvB1XJSwUeeT5afqHFeqyHaMa3LB5N12eN2PoIBKSFcp6l4SaH3IaRFDIbOA815Nc3DHbSLIGvi00yGQQ2QfI%3D&uds=AJ5uw1-CsN_VmOWvV4nQCD6b3IOK_JbUvbBGQOpQ8nI1PecTQFfXYVNR8ehKlyMUSPn6zIBOHT9_VCYd8wOI5D7RV1OAvnPBnyjPABVZX5Ls1tc61vfO-UQ"

const subject = "PAT Testing Quote Request"
const body = [
  "Company name:",
  "Contact name:",
  "Phone:",
  "Address:",
  "Type of business:",
  "Test due date:",
  "Number of tests required:",
  "How did you hear about us?:",
  "",
].join("\n")

export const MAILTO = `mailto:${EMAIL}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`
