# academia-migrate

I developed this application to migrate scholarly publications from the pseudo-open Academia.edu into Zenodo.org, which is a truly open platform for the dissemination of research data and publications. Zenodo is developed by CERN and backed by EU funding. This application extracts publication metadata (with PHP) from an Academia.edu user profile and facilitates import of this metadata (if there are associated document files) and re-upload of these document files into Zenodo.

Despite Academia.edu's (poor) terms of service, Google's recent victory over academic publishers has demonstrated that metadata are not copyrightable, and can be freely harvested from the web. However, the document files cannot be harvested automatically (only authenticated users can download them), and so there needs to be an intermediate step in which Academia users re-upload their files into this system for posting via API into Zenodo. Upon completion of the migration process, these uploaded files will be deleted from this server.

This framework relies on a PHP script for scraping metadata from Academia.edu and posting files at multipart/form-data. The remaining interactions are handled in Orbeon, an XForms processor.
