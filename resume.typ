#import "cv.typ": *

// Load CV data from YAML
#let cvdata = yaml("resume.yml")

#let uservars = (
  headingfont: "Libertinus Serif", // Set font for headings
  bodyfont: "Libertinus Serif", // Set font for body
  footerfont: "IBM Plex Mono", // Set font for end note/footer
  fontsize: 10pt, // 10pt, 11pt, 12pt
  linespacing: 6pt,
  showAddress: true, // true/false Show address in contact info
  showNumber: false, // true/false Show phone number in contact info
  showPostal: false, // Boolean for full address
  showCerts: false, // Boolean for certificates
  showEducationDates: false, // Boolean for showing full start and end date
  showProjects: false,
  showReferences: true, // Show references
  linkReferences: false, // Some ATS get confused by links and pick up these links instead of my own
)

// setrules and showrules can be overridden by re-declaring it here
// #let setrules(doc) = {
//      // Add custom document style rules here
//
//      doc
// }

#let customrules(doc) = {
  // Add custom document style rules here

  doc
}

#let cvinit(doc) = {
  doc = setrules(uservars, doc)
  doc = showrules(uservars, doc)
  doc = customrules(doc)

  doc
}

// Each section function can be overridden by re-declaring it here
// #let cveducation = []

// Content
#show: doc => cvinit(doc)

#cvheading(cvdata, uservars)

#cvsummary(cvdata)
#cvimpact(cvdata)
#cvskills(cvdata)
#cvwork(cvdata)
#cveducation(cvdata, uservars)
#cvaffiliations(cvdata)
#cvprojects(cvdata, uservars)
#cvawards(cvdata)
#cvcertificates(cvdata, uservars)
#cvpublications(cvdata)
#cvreferences(cvdata, uservars)

#pdf.attach(
  "resume.yml",
  relationship: "source",
  mime-type: "text/yaml",
  description: "Raw CV Data in YAML format, with extra info, machine-friendly",
)

#endnote(cvdata, uservars)
