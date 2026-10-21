#import "cv.typ": *
#import "utils.typ"

// Load CV data from YAML
#let cvdata = yaml("resume.yml")

// Calculate references by joining work references in the order they appear
#{
  let work_refs = ()
  if utils.hasvalid(cvdata, "work") {
    for w in cvdata.work {
      if utils.hasvalid(w, "references") and type(w.references) == array {
        for ref in w.references {
          work_refs.push(ref)
        }
      }
    }
  }
  cvdata.insert("references", work_refs)
}

#let uservars = (
  headingfont: "IBM Plex Serif", // Set font for headings
  bodyfont: (
    name: "Inter",
    weight: "medium",
    size: 9.5pt, // 10pt, 11pt, 12pt
  ), // Set font for body
  footerfont: "IBM Plex Mono", // Set font for end note/footer
  linespacing: 4.5pt,
  showAddress: sys.inputs.at("show_address", default: "true") == "true",
  showNumber: sys.inputs.at("show_number", default: "false") == "true",
  showPostal: sys.inputs.at("show_postal", default: "false") == "true",
  showCerts: sys.inputs.at("show_certs", default: "false") == "true",
  showEducationDates: sys.inputs.at("show_education_dates", default: "false") == "true",
  showAwards: sys.inputs.at("show_awards", default: "false") == "true",
  showProjects: sys.inputs.at("show_projects", default: "false") == "true",
  showReferences: sys.inputs.at("show_references", default: "true") == "true",
  linkReferences: sys.inputs.at("link_references", default: "false") == "true",
  embedYaml: sys.inputs.at("embed_yml", default: "true") == "true",
  embedDiploma: sys.inputs.at("embed_diploma", default: "true") == "true",
  embedCertificates: sys.inputs.at("embed_certs", default: "true") == "true",
  maxWorkExperiences: int(sys.inputs.at("max_work_experiences", default: "0")),
)

#let full_cvdata = cvdata
#let visible_cvdata = cvdata

#{
  let max_work = uservars.maxWorkExperiences
  if max_work > 0 and utils.hasvalid(cvdata, "work") and cvdata.work.len() > max_work {
    let sliced_work = cvdata.work.slice(0, max_work)
    let sliced_refs = ()
    for w in sliced_work {
      if utils.hasvalid(w, "references") and type(w.references) == array {
        for ref in w.references {
          sliced_refs.push(ref)
        }
      }
    }
    visible_cvdata = cvdata
    visible_cvdata.insert("work", sliced_work)
    visible_cvdata.insert("references", sliced_refs)
    visible_cvdata.insert("omitted_work_count", cvdata.work.len() - max_work)
  }
}

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
  doc = setrules(uservars, full_cvdata, doc)
  doc = showrules(uservars, doc)
  doc = customrules(doc)

  doc
}

// Each section function can be overridden by re-declaring it here
// #let cveducation = []

// Content
#show: doc => cvinit(doc)

#cvheading(visible_cvdata, uservars)

#cvsummary(visible_cvdata)
#cvimpact(visible_cvdata)
#cvskills(visible_cvdata)
#cvwork(visible_cvdata)
#cveducation(visible_cvdata, uservars)
#cvaffiliations(visible_cvdata)
#cvprojects(visible_cvdata, uservars)
#cvawards(visible_cvdata, uservars)
#cvcertificates(visible_cvdata, uservars)
#cvpublications(visible_cvdata)
#cvreferences(visible_cvdata, uservars)

#context {
  if target() == "html" {
    endnote(full_cvdata, uservars)
  }
}

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

  if not uservars.showReferences {
    newcvdata = utils.removekey(newcvdata, "references")
    if utils.hasvalid(newcvdata, "work") {
      newcvdata.work = newcvdata.work.map(job => utils.removekey(job, "references"))
    }
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

#makeEmbeds(full_cvdata, uservars)
