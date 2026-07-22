#import "cv.typ": *
#import "utils.typ"

// Load CV data from YAML
#let cvdata = yaml("resume.yml")

#let uservars = (
  headingfont: "IBM Plex Serif", // Set font for headings
  bodyfont: (
    name: "Inter",
    weight: "medium",
    size: 9.5pt, // 10pt, 11pt, 12pt
  ), // Set font for body
  footerfont: "IBM Plex Mono", // Set font for end note/footer
  linespacing: 4.5pt,
  showAddress: true, // true/false Show address in contact info
  showNumber: false, // true/false Show phone number in contact info
  showPostal: false, // Boolean for full address
  showCerts: false, // Boolean for certificates
  showEducationDates: false, // Boolean for showing full start and end date
  showAwards: false,
  showProjects: false,
  showReferences: true, // Show references
  linkReferences: false, // Some ATS get confused by links and pick up these links instead of my own
  embedYaml: sys.inputs.at("embed_yml", default: "true") == "true",
  embedDiploma: sys.inputs.at("embed_diploma", default: "true") == "true",
  embedCertificates: sys.inputs.at("embed_certs", default: "true") == "true",
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
  doc = setrules(uservars, cvdata, doc)
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
#cvawards(cvdata, uservars)
#cvcertificates(cvdata, uservars)
#cvpublications(cvdata)
#cvreferences(cvdata, uservars)

#let makeEmbeds(cvdata, uservars) = {
  let newcvdata = cvdata

  if not uservars.showProjects {
    let _ = newcvdata.remove("projects")
  }

  if not uservars.showCerts {
    let _ = newcvdata.remove("certificates")
  }

  if not uservars.showAwards {
    let _ = newcvdata.remove("awards")
  }

  if not uservars.showPostal {
    newcvdata.personal.location = utils.removekey(newcvdata.personal.location, "postalCode")
  }

  if not uservars.showAddress {
    newcvdata.insert("personal", utils.removekey(newcvdata.personal, "location"))
  }

  if not uservars.showNumber {
    newcvdata.insert("personal", utils.removekey(newcvdata.personal, "phone"))
  }

  if uservars.embedYaml {
    pdf.attach(
      "resume.yml",
      bytes(yaml.encode(newcvdata)),
      relationship: "source",
      mime-type: "text/yaml",
      description: "Raw CV Data in YAML format, with extra info, machine-friendly",
    )
  }

  if uservars.embedDiploma {
    pdf.attach(
      "diploma.pdf",
      relationship: "supplement",
      mime-type: "application/pdf",
      description: "Diploma PDF",
    )
  }

  if uservars.embedCertificates {
    for cert in cvdata.certificates {
      pdf.attach(
        cert.filename,
        relationship: "supplement",
        mime-type: "application/pdf",
        description: cert.name + " by " + cert.issuer,
      )
    }
  }
}

#makeEmbeds(cvdata, uservars)
