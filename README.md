# Artifact Cleanup Plugin

* Reject repos higher than limit in bash and log - DONE
* Validate day/month & non positive interval - DONE
* Multi repo support in Aql - DONE in JS
* Calculate correct timestamp - DONE
* Add delete command with delay - DONE
* Add a property bag resource to see the output & keeping it extensible - DONE
* Test with different type of repos - TODO
* Test cron - TODO
* Make bash functions - DONE
* Print simple report - ?
* Download simple report - DONE
* Documentation for teams
* Open PR


Questions:
* Created before but never downloaded ? YES
* Batch delete (if yes then will delay work as batch delay)? NO
* dryRun: true default - YES (ADDED)
* Reports
    - Repo path - YES
    - Deleted at - YES (Check if deleted)
    - Last downloaded time - ?
    - Need to log permissions errors?
* Load test
    - Scenarios related to Pipelines timeout