xquery version "1.0-ml";

declare namespace db = 'http://marklogic.com/xdmp/database';
declare namespace a = 'http://marklogic.com/xdmp/assignments';

(: pretty print :)
declare option xdmp:indent 'yes';

declare variable $config-dir := '/path/to/configuration-dir/';
declare variable $dbsxml := xdmp:document-get ($config-dir||'databases.xml');
declare variable $axml := xdmp:document-get ($config-dir||'assignments.xml');

declare variable $local:debug := fn:false();

declare function local:forest-name-from-id ($forest-id) {
    ($axml//a:assignment[a:forest-id/fn:data() = $forest-id]/a:forest-name/fn:string(), '#######')[1]
};

declare function local:sort-key ($node as node()) {
  typeswitch($node)
      case element() return 
          if (fn:node-name ($node) eq xs:QName ('db:database')) then
              fn:string ($node/db:database-name)
          else if (fn:node-name ($node) = (xs:QName ('db:field'), xs:QName ('db:range-field-index'))) then
              fn:string ($node/db:field-name)
          else if (fn:node-name ($node) eq xs:QName ('db:field-path')) then
              fn:string ($node/db:path)
          else if (fn:node-name ($node) eq xs:QName ('db:path-namespace')) then
              concat(fn:string($node/db:namespace-uri), '=', fn:string($node/db:prefix))
          else if (fn:node-name ($node) eq xs:QName ('db:forest-id')) then
              fn:count ($node/preceding-sibling::db:forest-id)
          else if (fn:exists ($node/db:localname)) then
              fn:string-join (($node/db:localname,$node/db:parent-localname,$node/db:namespace-uri)/fn:string(), '+')
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
          if (fn:node-name ($node/parent::*) = ('db:database-id' ! xs:QName (.))) then
                '#######'
          else if (fn:node-name ($node/parent::*) = ('db:forest-id' ! xs:QName (.))) then
                ($axml//a:assignment[a:forest-id/fn:data() = xs:unsignedLong($node)]/a:forest-name/fn:string(), '#######')[1]
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

let $new := local:change ($dbsxml)
return (
    xdmp:save ('/Users/hamlin/tmp/new.xml', document {$new} )
)


