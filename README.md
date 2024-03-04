# confdiff

normalize the xml config files so it's easy to diff, for example via

macvim -d dbs1.xml dbs2.xml

It does this by sorting the elements/attributes by name or by more specific identifiers.  IDs are normalized to a single value.

Works on databases.xml.

**NOTE:  the output is used for diff analysis.  It can't be used as configuration for MarkLogic Server.**

set 'debug' param to true to show the keys preceding the elements in the output.

add to the sortkey function as needed.

Just put the xqy in QC, point to your source databases.xml and where you want to to be saved (if you do), and you get a normalized version.  If you normalize the databases.xml from two clusters you can compare them and see any differences.

Tested in MarkLogic 11 QC.

Testing means:  looked OK on one pair of databases.xml.


Ignore the xslt.  I'll get rid of it or update it someday.
