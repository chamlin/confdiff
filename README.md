# confdiff

normalize the xml config files so it's easy to diff, for example via

macvim -d dbs1.xml dbs2.xml

It does this by sorting the elements/attributes by name or by more specific identifiers.  IDs are normalized to a single value.

Works on databases.xml

Tested in MarkLogic 11 QC.

Testing means:  looked OK on one pair of databases.xml.

set 'debug' param to true to show the keys preceding the elements in the output.

add to the sortkey function as needed.



Ignore the xslt.  I'll get rid of it or update it someday.
