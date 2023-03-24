# confdiff

normalize the xml config files so it's easy to diff, for example via

mvim -d

It does this by sorting the elements by name or by more specific identifiers.

First, working on databases.xml

Tested in ancient Oxygen and MarkLogic 11.

Testing means:  looked OK on one databases.xml.

set 'debug' param to true to show the keys preceding the elements in the output.

add to the sortkey function as needed.

Example QC code:

```xquery
let $xsl := xdmp:document-get ('/Users/chamlin/git/confdiff/xmlnorm.xsl')
let $xml := xdmp:document-get ('/Users/chamlin/git/confdiff/aws.xml')
let $new := xdmp:xslt-eval ($xsl, $xml)
return $new
```
