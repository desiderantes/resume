#import "@preview/based:0.2.0": base64
#import "utils.typ"

// show rules
#let showrules(uservars, doc) = {
  // Uppercase Section Headings
  show heading.where(
    level: 2,
  ): it => block(width: 100%)[
    #set align(left)
    #set text(font: uservars.headingfont, size: 1em, weight: "bold")
    #upper(it.body)
    #v(-0.75em) #line(length: 100%, stroke: 1pt + black) // Draw a line
  ]

  // Name Title
  show heading.where(
    level: 1,
  ): it => block(width: 100%)[
    #set text(font: uservars.headingfont, size: 1.5em, weight: "bold")
    #upper(it.body)
    #v(2pt)
  ]

  doc
}



// Address
#let addresstext(info, uservars) = {
  if uservars.showAddress {
    block(width: 100%)[
      #info.personal.location.city, #info.personal.location.region, #info.personal.location.country #{ if uservars.showPostal {
        [#info.personal.location.postalCode]
      } }
      #v(-4pt)
    ]
  } else { none }
}

// Arrange the contact profiles with a diamond separator
#let contacttext(info, uservars) = block(width: 100%)[
  // Contact Info
  // Create a list of contact profiles
  #let profiles = (
    box(link("mailto:" + info.personal.email)),
    if uservars.showNumber { box(link("tel:" + info.personal.phone)) } else { none },
    box(link(info.personal.url)[#info.personal.url.split("//").at(1)]),
  ).filter(it => it != none) // Filter out none elements from the profile array

  // Add any social profiles
  #if info.personal.profiles.len() > 0 {
    for profile in info.personal.profiles {
      profiles.push(
        box(link(profile.url)[#profile.url.split("//").at(1)]),
      )
    }
  }

  // #set par(justify: false)
  #set text(font: uservars.bodyfont.name, weight: uservars.bodyfont.weight, size: uservars.bodyfont.size * 1)
  #pad(x: 0em)[
    #profiles.join([#sym.space.nobreak.narrow #sym.diamond.filled #sym.space.nobreak.narrow])
  ]
]

// Create layout of the title + contact info
#let cvheading(info, uservars) = {
  align(center)[
    = #info.personal.name
    #addresstext(info, uservars)
    #contacttext(info, uservars)
    // #v(0.5em)
  ]
}

// Education
#let cveducation(info, uservars) = {
  if utils.hasvalid(info, "education") {
    block(breakable: false)[
      == Education
      #for edu in info.education {
        // Parse ISO date strings into datetime objects
        let start = utils.strpdate(edu.startDate)
        let end = utils.strpdate(edu.endDate)
        // Create a block layout for each education entry
        block(width: 100%)[
          // Line 1: Institution and Location
          *#link(edu.url)[#edu.institution]* #h(1fr) *#edu.location* \
          // Line 2: Degree and Date Range
          #text(style: "italic")[#edu.studyType in #edu.area] #h(1fr)
          #{
            if uservars.showEducationDates == true {
              [#start #sym.dash.en #end]
            }
          }
          #{
            if utils.hasvalid(edu, "honours") and edu.honours.len() > 0 {
              [- *Honours*: #edu.honours.join(", ")]
            }
          }
          #{
            if utils.hasvalid(edu, "courses") and edu.courses.len() > 0 {
              [- *Courses*: #edu.courses.join(", ")]
            }
          }
          #{
            if utils.hasvalid(edu, "highlights") {
              for hi in edu.highlights [- #hi]
            }
          }
        ]
      }
    ]
  }
}

// Work Experience
#let cvwork(info) = {
  if utils.hasvalid(info, "work") {
    block(breakable: true)[
      == Work Experience

      #for w in info.work {
        // Parse ISO date strings into datetime objects
        let start = utils.strpdate(w.startDate)
        let end = utils.strpdate(w.endDate)

        // Create a block layout for each education entry
        block(width: 100%, breakable: false)[
          // Line 1: Company and Location
          #{
            let org_name = w.organization.name
            let org_url = w.organization.at("url", default: none)
            let org_content = if org_url != none { link(org_url)[#org_name] } else { org_name }

            if w.keys().contains("client") {
              let client_name = w.client.name
              let client_url = w.client.at("url", default: none)
              let client_content = if client_url != none { link(client_url)[#client_name] } else { client_name }
              [*#client_content via #org_content*]
            } else { [*#org_content*] }
          } #h(1fr) *#w.location.join("/")* \
          // Line 2: Degree and Date Range
          #text(style: "italic")[#w.position] #h(1fr) #start #sym.dash.en #end \[ #(
            w.modality.map(mode => [ #smallcaps[#mode]]).join(", ")
          ) \]\
          // Highlights or Description
          #for hi in w.highlights [
            - #hi
          ]
        ]
      }
    ]
  }
}

// Leadership and Activities
#let cvaffiliations(info) = {
  if utils.hasvalid(info, "affiliations") {
    block(breakable: false)[
      == Leadership & Activities

      #for org in info.affiliations {
        // Parse ISO date strings into datetime objects
        let start = utils.strpdate(org.startDate)
        let end = utils.strpdate(org.endDate)

        // Create a block layout for each education entry
        block(width: 100%)[
          // Line 1: Institution and Location
          #{
            let org_content = if type(org.organization) == "string" {
              if org.keys().contains("url") { link(org.url)[#org.organization] } else { org.organization }
            } else {
              let org_name = org.organization.name
              let org_url = org.organization.at("url", default: none)
              if org_url != none { link(org_url)[#org_name] } else { org_name }
            }
            [*#org_content*]
          } #h(1fr) *#org.location* \
          // Line 2: Degree and Date Range
          #text(style: "italic")[#org.position] #h(1fr)
          #start #sym.dash.en #end \
          // Highlights or Description
          #if utils.hasvalid(org, "highlights") {
            for hi in org.highlights [
              - #hi
            ]
          } else {}
        ]
      }
    ]
  }
}

// Summary

#let cvsummary(info) = {
  {
    block(breakable: true)[
      == Summary

      #text(info.summary)
    ]
  }
}

// Impact
#let cvimpact(info) = {
  if utils.hasvalid(info, "impact") {
    block(breakable: true)[
      == Impact
      #for item in info.impact [
        - #item
      ]
    ]
  }
}
// Projects
#let cvprojects(info, uservars) = {
  if utils.hasvalid(info, "projects") and uservars.showProjects == true {
    block(breakable: true)[
      == Projects

      #for project in info.projects {
        // Parse ISO date strings into datetime objects
        let start = utils.strpdate(project.startDate)
        let end = utils.strpdate(project.endDate)

        // Create a block layout for each education entry
        block(width: 100%, breakable: false)[
          // Line 1: Institution and Location
          *#link(project.url)[#project.name]* \
          // Line 2: Degree and Date Range
          #text(style: "italic")[#project.affiliation]  #h(1fr) #start #sym.dash.en #end \
          // Summary or Description
          #for hi in project.highlights [
            - #hi
          ]
        ]
      }
    ]
  }
}

// Honors and Awards
#let cvawards(info, uservars) = {
  if utils.hasvalid(info, "awards") and uservars.showAwards {
    block(breakable: false)[
      == Honors & Awards

      #for award in info.awards {
        // Parse ISO date strings into datetime objects
        let date = utils.strpdate(award.date)

        // Create a block layout for each education entry
        block(width: 100%)[
          // Line 1: Institution and Location
          *#link(award.url)[#award.title]* #h(1fr) *#award.location*\
          // Line 2: Degree and Date Range
          Issued by #text(style: "italic")[#award.issuer]  #h(1fr) #date \
          // Summary or Description
          #if utils.hasvalid(award, "highlights") {
            for hi in award.highlights [
              - #hi
            ]
          } else {}
        ]
      }
    ]
  }
}

// Certifications
#let cvcertificates(info, uservars) = {
  if (utils.hasvalid(info, "certificates")) and uservars.showCerts {
    block(breakable: false)[
      == Licenses & Certifications

      #for cert in info.certificates {
        // Parse ISO date strings into datetime objects
        let date = utils.strpdate(cert.date)

        // Create a block layout for each education entry
        block(width: 100%)[
          // Line 1: Institution and Location
          *#link(cert.url)[#cert.name]* \
          // Line 2: Degree and Date Range
          Issued by #text(style: "italic")[#cert.issuer]  #h(1fr) #date \
        ]
      }
    ]
  }
}

// Research & Publications
#let cvpublications(info) = {
  if utils.hasvalid(info, "publications") {
    block(breakable: false)[
      == Research & Publications

      #for pub in info.publications {
        // Parse ISO date strings into datetime objects
        let date = utils.strpdate(pub.releaseDate)

        // Create a block layout for each education entry
        block(width: 100%)[
          // Line 1: Institution and Location
          *#link(pub.url)[#pub.name]* \
          // Line 2: Degree and Date Range
          Published on #text(style: "italic")[#pub.publisher]  #h(1fr) #date \
        ]
      }
    ]
  }
}

// Skills, Languages, and Interests
#let cvskills(info) = {
  if (utils.hasvalid(info, "languages")) or (utils.hasvalid(info, "work")) or (utils.hasvalid(info, "interests")) {
    block(breakable: false)[
      == Skills, Languages, Interests

      #if (utils.hasvalid(info, "languages")) [
        #let langs = ()
        #for lang in info.languages {
          langs.push([#lang.language (#lang.fluency)])
        }
        - *Languages*: #langs.join(", ")
      ]
      #if (utils.hasvalid(info, "work")) [
        #let skill_map = (:) // category -> (tech_name -> (version_list))

        #for job in info.work {
          if utils.hasvalid(job, "stack") {
            for item in job.stack {
              let cat = item.at("category", default: "Other")
              let name = item.name

              if cat not in skill_map { skill_map.insert(cat, (:)) }

              // Get existing versions for this tech in this category
              let current_versions = skill_map.at(cat).at(name, default: ())

              if utils.hasvalid(item, "versions") {
                for v in item.versions {
                  let v_str = str(v)
                  if v_str not in current_versions { current_versions.push(v_str) }
                }
              }

              // Update the map with the merged version list
              skill_map.at(cat).insert(name, current_versions)
            }
          }
        }

        // Define a preferred order for categories
        #let category_order = ("Programming", "Backend", "Tools", "BI & Data Analytics")
        #let existing_cats = category_order + skill_map.keys().filter(it => it not in category_order)




        // Render ordered categories first, then any others found
        #for cat in existing_cats {
          if cat in skill_map.keys() {
            let items = skill_map.at(cat)
            let formatted_list = ()

            for (name, versions) in items {
              if versions.len() > 0 {
                // FIX: Map strings to integers/floats for correct numeric sorting
                // This ensures 5 and 8 appear before 11 and 25
                let sorted_v = versions.sorted(key: v => {
                  let clean_v = v.replace(regex("[^\d.]"), "")
                  if clean_v == "" { return 0 }
                  float(clean_v)
                })

                formatted_list.push([#name (#sorted_v.join(", "))])
              } else {
                formatted_list.push([#name])
              }
            }
            [- *#cat*: #formatted_list.join(", ")]
          }
        }
      ]
      #if (utils.hasvalid(info, "interests")) [
        - *Interests*: #info.interests.join(", ")
      ]
    ]
  }
}

// References
#let cvreferences(info, uservars) = {
  if (utils.hasvalid(info, "references") and uservars.showReferences) {
    block(breakable: false)[
      == References

      #for ref in info.references [
        #if uservars.linkReferences [
          - *#link(ref.url)[#ref.name]*: "#ref.reference"
        ] else [
          - *#ref.name*: "#ref.reference"
        ]
      ]
    ]
  } else {}
}

// #cvreferences

// =====================================================================

// End Note
#let endnote(info, uservars) = context {
  let date = datetime.today().display("[year]-[month]-[day]")
  let is_html = target() == "html"
  let link_text = "YAML file"

  let content = [
    #set text(size: 5pt, font: uservars.footerfont, fill: silver)
    This document was last updated on #date.
    #{
      if uservars.embedYaml {
        [ There is a ]
        if is_html {
          let yml_str = yaml.encode(info)
          let yml_b64 = base64.encode(yml_str)
          html.a(download: "resume.yml", href: "data:text/yaml;base64, " + yml_b64, link_text)
        } else {
          link("attach:resume.yaml", link_text)
        }
        [ embedded for AI Agents that has the info in this file, and more. ]
      }
    }
    Source code: #link("https://github.com/desiderantes/resume")[github.com/desiderantes/resume]
  ]

  content
}


// set rules
#let setrules(uservars, info, doc) = {
  set page(
    paper:
    //"us-legal",
    "a4",
    //"us-letter",
    numbering: "1 / 1",
    number-align: center, // left, center, right
    margin: (
      top: 1.25cm,
      bottom: 1.75cm,
      x: 1.5cm
    ),
    header: context {
      if counter(page).get().first() > 1 [
        #set text(size: 8pt, fill: color.linear-rgb(47, 47, 47, 255))
        #info.personal.name
        #h(1fr)
        #info.personal.title
        #v(-4pt)
        #line(length: 100%, stroke: 0.5pt + gray)
      ]
    },
    footer: context {
      let current = counter(page).get().first()
      let total = counter(page).final().first()
      align(center)[
        #if current == total {
          endnote(info, uservars)
          v(3pt)
        }
        #counter(page).display("1 / 1", both: true)
      ]
    }
  )

  // Set Text settings
  set text(
    font: uservars.bodyfont.name,
    size: uservars.bodyfont.size,
    hyphenate: false,
  )

  // Set Paragraph settings
  set par(
    leading: uservars.linespacing,
    justify: true,
  )

  doc
}
