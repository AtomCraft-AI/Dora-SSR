-- The Agent reloads this entry point. The client keeps short-lived credentials
-- in its private closure across commands, without writing them to disk.
return require("Doc.skills.atompie-submission.client")
