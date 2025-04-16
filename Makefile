.DELETE_ON_ERROR:

top: main
dirs := tmp out
$(dirs):; mkdir -p $@
base := HeuristNetwork/heurist
main :=

# Comments by Gemini 2.5 pro (required multiple itérations and have to
# give him part of the doc)
ifdef NEVER
# Set dependencies/prerequisites for the subsequent rule in the ']' variable.
# This name is used by '$]:' prefixed lines below, which expand to standard Make
# target-specific variable assignments (target: variable := value).
] := target_file.out

# Define a target-specific variable 'helper_var' for the target 'target_file.out'.
# '$]:' expands to 'target_file.out:', creating 'target_file.out: helper_var :=...'
$]: helper_var := some_value

# Define a target-specific variable named after the target itself ('target_file.out')
# and assign the recipe command string to it.
# '$]: $]' expands to 'target_file.out: target_file.out :=...'
$]: $] := echo Processing $< using $(helper_var)

# Define the rule execution logic using target-specific context.
# '$]:' expands to 'target_file.out:', creating the start of a rule definition.
# '$[' expands the prerequisites stored in the '[' variable.
# '$($@)' expands the target-specific variable named after the target ($@), executing
# the recipe stored via the '$]: $] :=...' assignment above.
# Standard Make constructs like '< $<' (input redirection) and '> $@' (output redirection)
# are used within the execution structure.
$]: $[; < $< $($@) > $@
endif

# Comment by lazy human
# To grok `target: | order-only-prerequisites; recipe`
# like in `$]: | tmp; $($@) > $@`
# see https://www.gnu.org/software/make/manual/html_node/Prerequisite-Types.html

] := tmp/file.js
$]: grep := ^./([.]git|tmp)/
$]: jq := (. / "/")[-1] as $$name | ($$name / ".") as $$dot
$]: jq += | select($$dot | first != "" and length > 1) | [ ., $$name, $$dot[-1] ]
$]: $] := (cd $(base); find -type f | grep -Ev '$(grep)' | jq -Rc '$(jq)')
$]: | tmp; $($@) > $@

[ := $]
] := tmp/keep.js
$]: jq := select(last | [test("php", "htm", "js", "sh", "sql", "css")] | any)[:-1]
$]: $] := jq '$(jq)' -c
$]: $[; < $< $($@) > $@

[ := $]
] := tmp/path.txt
$]: jq := map(first) | sort[]
$]: $] := jq '$(jq)' -sr
$]: $[; < $< $($@) > $@

] := tmp/name.txt
$]: jq := map(last) | sort[]
$]: $] := jq '$(jq)' -sr
$]: $[; < $< $($@) > $@

[ := $]
] := $([:%.txt=%.js)
$]: jq := [inputs]
$]: $] := jq '$(jq)' -nR
$]: $[; < $< $($@) > $@

[ := tmp/name.txt tmp/path.txt
] := tmp/grep.txt
$]: $] = < $(lastword $^) tr '\n' '\0' | xargs -0 proot -w $(base) grep -nf $$(realpath $<) > $@
$]: $[; $($@) > $@

[ := $]
] := tmp/grep.js
$]: jq := (. / ":") as [ $$path, $$line, $$txt ] | ($$path / "/")[-1] as $$name
$]: jq += | ($$line | tonumber) as $$line | { $$name, $$path, $$line, $$txt }
$]: $] := jq '$(jq)' -Rr
$]: $[; < $< $($@) > $@

[ := tmp/name.js $]
] := tmp/ref.js
$]: jq := input as $$names | inputs | $$names[] as $$name
$]: jq += | if .txt | test($$name) then .use += [$$name] else empty end
$]: $] = cat $^ | jq '$(jq)' -nc
$]: $[; $($@) > $@

[ := $]
] := tmp/name2path.js
$]: jq := INDEX(map([.name, .path])[]; first) | map_values(last)
$]: $] = jq '$(jq)' -s
$]: $[; < $< $($@) > $@
main += $]

] := tmp/use.js
$]: jq := map({ name, line, use }) | group_by(.name)
$]: jq += | map({ name: .[0].name, use: map({ name: .use[0], line })})[]
$]: $] := jq '$(jq)' -sc
$]: $[; < $< $($@) > $@
main += $]

] := tmp/isin.js
$]: jq := map({ name, line, use }) | group_by(.use[0])
$]: jq += | map({ name: .[0].use[0], isin: map({ name: .name, line })})[]
$]: $] := jq '$(jq)' -sc
$]: $[; < $< $($@) > $@

main: $(main) $]

~ := install
$~ := name2path use isin
[ := $($~:%=tmp/%.js)
$~: $[ | out; install -t $| $^
