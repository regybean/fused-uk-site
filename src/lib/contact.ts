export const EMAIL = "sales@fuseduk.co.uk"
export const PHONE = "07729 577307"
export const TEL = "tel:07729577307"

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
