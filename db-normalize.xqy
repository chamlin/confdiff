declare namespace db = 'http://marklogic.com/xdmp/database';
(: pretty print :)
declare option xdmp:indent 'yes';

declare variable $local:debug := fn:false();

declare function local:sort-key ($node as node()) as xs:string {
  typeswitch($node)
      case element() return 
          if (fn:node-name ($node) eq xs:QName ('db:database')) then
              fn:string ($node/db:database-name)
          else if (fn:node-name ($node) eq xs:QName ('db:path-namespace')) then
              concat(fn:string($node/db:namespace-uri), '=', fn:string($node/db:prefix))
          else if (fn:exists ($node/db:localname)) then
              fn:string-join ($node/(db:parent-localname|db:localname)/fn:string(), '+')
          else
              fn:local-name ($node)
      case attribute() return 
          fn:local-name ($node)
      default return fn:string ($node)
 
};

declare function local:expand-element-by-localname ($e as element()) {
    let $localnames :=
            for $s in $e/db:localname/fn:string()
            for $t in fn:tokenize (fn:normalize-space ($s), ' ')
            return $t
    return (
        if (fn:count ($localnames) <= 1) then
            $e
        else 
            for $ln in $localnames 
            return
                element { fn:node-name ($e) } {
                    $e/@*,
                    for $e in $e/node()
                    order by local:sort-key ($e)
                    return
                        if (fn:node-name ($e) eq xs:QName ('db:localname')) then 
                            <db:localname>{$ln}</db:localname>
                        else 
                            $e
                }
    )
};

declare function local:change ($node) {
  typeswitch($node)
      case document-node() return 
          local:change ($node/*)
      case processing-instruction() return 
          $node
      case comment() return
          $node
      case text() return 
          if (fn:node-name ($node/parent::*) = (('db:forest-id', 'db:database-id') ! xs:QName (.))) then
                '999999'
          else 
                $node
      case element() return 
            element { fn:node-name ($node) } {
                for $a in $node/@*
                order by local:sort-key ($a)
                return $a
                ,
                let $kids := 
                    for $n in $node/node()
                    return
                        if ($n/element()) then local:expand-element-by-localname ($n)
                        else $n
                for $k in $kids
                let $sort-key := local:sort-key ($k)
                order by $sort-key
                return (
                    if ($local:debug) then <sort-key>{$sort-key}</sort-key> else (),
                    local:change ($k)
                )
            }
      default return fn:error(xs:QName("ERROR"), 'huh? local:change of '||xdmp:describe ($node, (), ()))
};


let $xml := xdmp:document-get ('/Users/hamlin/git/confdiff/databases-test.xml')
let $new := local:change ($xml)
return (
    $new,
    xdmp:save ('/Users/hamlin/git/confdiff/x.xml', document {$new} )
)


