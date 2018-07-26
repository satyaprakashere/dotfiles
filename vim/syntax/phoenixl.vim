" Vim syntax file
" Language: Phoenix
" Maintainer: Satya Prakash <satyapr93@gmail.com>
" Last Change: 2015 26 Dec

if exists("b:current_syntax")
  finish
endif

" syncing starts 2000 lines before top line so docstrings don't screw things up
"syn sync minlines=2000

syn cluster phoenixNotTop contains=@phoenixRegexSpecial,@phoenixStringContained,@phoenixDeclaration,phoenixTodo,phoenixArguments

syn match phoenixComment ';.*' contains=phoenixTodo
syn keyword phoenixTodo FIXME NOTE TODO OPTIMIZE XXX HACK contained

syn keyword phoenixKeyword match when cond for if unless try receive send
syn keyword phoenixKeyword exit raise throw after rescue catch else do end data class where type define Kind Type value extension typeOf
syn keyword phoenixKeyword quote unquote super with fanily

syn keyword phoenixLet let val
" Functions used on guards
syn keyword phoenixKeyword contained is_atom is_binary is_bitstring is_boolean
syn keyword phoenixKeyword contained is_float is_function is_integer is_list
syn keyword phoenixKeyword contained is_map is_number is_pid is_port is_record
syn keyword phoenixKeyword contained is_reference is_tuple is_exception abs
syn keyword phoenixKeyword contained bit_size byte_size div elem head length
syn keyword phoenixKeyword contained map_size node rem round tail trunc tuple_size

syn match phoenixGuard '.*when.*' contains=ALLBUT,@phoenixNotTop

syn keyword phoenixInclude import require alias use hiding except from law constraint of

syn keyword phoenixSelf self

syn match phoenixId '\<[_a-zA-Z]\w*[!?]\?\>'

" This unfortunately also matches function names in function calls
syn match phoenixUnusedVariable '\<_\w*\>'

syn keyword phoenixOperator and not or when xor in
syn match   phoenixOperator '!==\|!=\|!'
syn match   phoenixOperator '=\~\|===\|==\|='
syn match   phoenixOperator '<<<\|<<\|<=\|<-\|<'
syn match   phoenixOperator '>>>\|>>\|>=\|>'
syn match   phoenixOperator '->\|--\|-'
syn match   phoenixOperator '++\|+'
syn match   phoenixOperator '&&&\|&&\|&'
syn match   phoenixOperator '|||\|||\||>\||'
syn match   phoenixOperator '\.\.\|\.'
syn match   phoenixOperator "\^\^\^\|\^"
syn match   phoenixOperator '\\\\\|::\|\*\|/\|\~\~\~\|@'

syn match   phoenixAtom '\(:\)\@<!:\%([a-zA-Z_]\w*\%([?!]\|=[>=]\@!\)\?\|<>\|===\?\|>=\?\|<=\?\)'
syn match   phoenixAtom '\(:\)\@<!:\%(<=>\|&&\?\|%\(()\|\[\]\|{}\)\|++\?\|--\?\|||\?\|!\|//\|[%&`/|]\)'
syn match   phoenixAtom "\%([a-zA-Z_]\w*[?!]\?\):\(:\)\@!"

syn match   phoenixAlias '\<[A-Z]\w*\(\.[A-Z]\w*\)*\>'

syn keyword phoenixBoolean true false nil

syn match phoenixVariable '@[a-z]\w*'
syn match phoenixVariable '&\d\+'

syn keyword phoenixPseudoVariable __FILE__ __DIR__ __MODULE__ __ENV__ __CALLER__

syn match phoenixNumber '\<\d\(_\?\d\)*\(\.[^[:space:][:digit:]]\@!\(_\?\d\)*\)\?\([eE][-+]\?\d\(_\?\d\)*\)\?\>'
syn match phoenixNumber '\<0[xX][0-9A-Fa-f]\+\>'
syn match phoenixNumber '\<0[bB][01]\+\>'

syn match phoenixRegexEscape            "\\\\\|\\[aAbBcdDefGhHnrsStvVwW]\|\\\d\{3}\|\\x[0-9a-fA-F]\{2}" contained
syn match phoenixRegexEscapePunctuation "?\|\\.\|*\|\\\[\|\\\]\|+\|\\^\|\\\$\|\\|\|\\(\|\\)\|\\{\|\\}" contained
syn match phoenixRegexQuantifier        "[*?+][?+]\=" contained display
syn match phoenixRegexQuantifier        "{\d\+\%(,\d*\)\=}?\=" contained display
syn match phoenixRegexCharClass         "\[:\(alnum\|alpha\|ascii\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|word\|xdigit\):\]" contained display

syn region phoenixRegex matchgroup=phoenixRegexDelimiter start="%r/" end="/[uiomxfr]*" skip="\\\\" contains=@phoenixRegexSpecial

syn cluster phoenixRegexSpecial    contains=phoenixRegexEscape,phoenixRegexCharClass,phoenixRegexQuantifier,phoenixRegexEscapePunctuation
syn cluster phoenixStringContained contains=phoenixInterpolation,phoenixRegexEscape,phoenixRegexCharClass

syn region phoenixString        matchgroup=phoenixStringDelimiter start="'" end="'" skip="\\'\|\\\\"
syn region phoenixString        matchgroup=phoenixStringDelimiter start='"' end='"' skip='\\"' contains=@phoenixStringContained
syn region phoenixInterpolation matchgroup=phoenixInterpolationDelimiter start="#{" end="}" contained contains=ALLBUT,phoenixComment,@phoenixNotTop

syn region phoenixDocStringStart matchgroup=phoenixDocString start=+"""+ end=+$+ oneline contains=ALLBUT,@phoenixNotTop
syn region phoenixDocStringStart matchgroup=phoenixDocString start=+'''+ end=+$+ oneline contains=ALLBUT,@phoenixNotTop
syn region phoenixDocString     start=+\z("""\)+ end=+^\s*\zs\z1+ contains=phoenixDocStringStart,phoenixTodo,phoenixInterpolation fold keepend
syn region phoenixDocString     start=+\z('''\)+ end=+^\s*\zs\z1+ contains=phoenixDocStringStart,phoenixTodo,phoenixInterpolation fold keepend

syn match phoenixAtomInterpolated   ':\("\)\@=' contains=phoenixString
syn match phoenixString             "\(\w\)\@<!?\%(\\\(x\d{1,2}\|\h{1,2}\h\@!\>\|0[0-7]{0,2}[0-7]\@!\>\|[^x0MC]\)\|(\\[MC]-)+\w\|[^\s\\]\)"

syn region phoenixBlock              matchgroup=phoenixKeyword start="\<do\>\(:\)\@!" end="\<end\>" contains=ALLBUT,@phoenixNotTop fold
syn region phoenixAnonymousFunction  matchgroup=phoenixKeyword start="\<fn\>"         end="\<end\>" contains=ALLBUT,@phoenixNotTop fold

syn region phoenixArguments start="(" end=")" contained contains=phoenixOperator,phoenixAtom,phoenixPseudoVariable,phoenixAlias,phoenixBoolean,phoenixVariable,phoenixUnusedVariable,phoenixNumber,phoenixDocString,phoenixAtomInterpolated,phoenixRegex,phoenixString,phoenixStringDelimiter,phoenixRegexDelimiter,phoenixInterpolationDelimiter,phoenixSigilDelimiter

syn match phoenixDelimEscape "\\[(<{\[)>}\]/\"'|]" transparent display contained contains=NONE

syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\u\z(/\|\"\|'\||\)" end="\z1" skip="\\\\\|\\\z1" contains=phoenixDelimEscape fold
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\u{"                end="}"   skip="\\\\\|\\}"   contains=phoenixDelimEscape fold
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\u<"                end=">"   skip="\\\\\|\\>"   contains=phoenixDelimEscape fold
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\u\["               end="\]"  skip="\\\\\|\\\]"  contains=phoenixDelimEscape fold
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\u("                end=")"   skip="\\\\\|\\)"   contains=phoenixDelimEscape fold

syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\l\z(/\|\"\|'\||\)" end="\z1" skip="\\\\\|\\\z1" fold
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\l{"                end="}"   skip="\\\\\|\\}"   fold contains=@phoenixStringContained,phoenixRegexEscapePunctuation
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\l<"                end=">"   skip="\\\\\|\\>"   fold contains=@phoenixStringContained,phoenixRegexEscapePunctuation
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\l\["               end="\]"  skip="\\\\\|\\\]"  fold contains=@phoenixStringContained,phoenixRegexEscapePunctuation
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start="\~\l("                end=")"   skip="\\\\\|\\)"   fold contains=@phoenixStringContained,phoenixRegexEscapePunctuation

" Sigils surrounded with docString
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start=+\~\a\z("""\)+ end=+^\s*\zs\z1+ skip=+\\"+ fold
syn region phoenixSigil matchgroup=phoenixSigilDelimiter start=+\~\a\z('''\)+ end=+^\s*\zs\z1+ skip=+\\'+ fold

" Defines
" syn keyword phoenixDefine              func            nextgroup=phoenixFunctionDeclaration    skipwhite skipnl
" syn keyword phoenixDefine              defunc            nextgroup=phoenixFunctionDeclaration    skipwhite skipnl
syn keyword phoenixPrivateDefine       funcp           nextgroup=phoenixFunctionDeclaration    skipwhite skipnl
syn keyword phoenixModuleDefine        module      nextgroup=phoenixModuleDeclaration      skipwhite skipnl
syn keyword phoenixProtocolDefine      protocol    nextgroup=phoenixProtocolDeclaration    skipwhite skipnl
syn keyword phoenixImplDefine          func        nextgroup=phoenixImplDeclaration        skipwhite skipnl
syn keyword phoenixImplDefine          instance        nextgroup=phoenixImplDeclaration        skipwhite skipnl
syn keyword phoenixRecordDefine        defrecord      nextgroup=phoenixRecordDeclaration      skipwhite skipnl
syn keyword phoenixPrivateRecordDefine defrecordp     nextgroup=phoenixRecordDeclaration      skipwhite skipnl
syn keyword phoenixMacroDefine         defmacro       nextgroup=phoenixMacroDeclaration       skipwhite skipnl
syn keyword phoenixPrivateMacroDefine  defmacrop      nextgroup=phoenixMacroDeclaration       skipwhite skipnl
syn keyword phoenixDelegateDefine      defdelegate    nextgroup=phoenixDelegateDeclaration    skipwhite skipnl
syn keyword phoenixOverridableDefine   defoverridable nextgroup=phoenixOverridableDeclaration skipwhite skipnl
syn keyword phoenixExceptionDefine     defexception   nextgroup=phoenixExceptionDeclaration   skipwhite skipnl
syn keyword phoenixCallbackDefine      defcallback    nextgroup=phoenixCallbackDeclaration    skipwhite skipnl
syn keyword phoenixStructDefine        defstruct      skipwhite skipnl

" Declarations
syn match  phoenixModuleDeclaration      "[^[:space:];#<]\+"        contained contains=phoenixAlias nextgroup=phoenixBlock     skipwhite skipnl
syn match  phoenixFunctionDeclaration    "[^[:space:];#<,()\[\]]\+" contained                      nextgroup=phoenixArguments skipwhite skipnl
syn match  phoenixProtocolDeclaration    "[^[:space:];#<]\+"        contained contains=phoenixAlias                           skipwhite skipnl
syn match  phoenixImplDeclaration        "[^[:space:];#<]\+"        contained contains=phoenixAlias                           skipwhite skipnl
syn match  phoenixRecordDeclaration      "[^[:space:];#<]\+"        contained contains=phoenixAlias,phoenixAtom                skipwhite skipnl
syn match  phoenixMacroDeclaration       "[^[:space:];#<,()\[\]]\+" contained                      nextgroup=phoenixArguments skipwhite skipnl
syn match  phoenixDelegateDeclaration    "[^[:space:];#<,()\[\]]\+" contained contains=phoenixFunctionDeclaration             skipwhite skipnl
syn region phoenixDelegateDeclaration    start='\['     end='\]'    contained contains=phoenixFunctionDeclaration             skipwhite skipnl
syn match  phoenixOverridableDeclaration "[^[:space:];#<]\+"        contained contains=phoenixAlias                           skipwhite skipnl
syn match  phoenixExceptionDeclaration   "[^[:space:];#<]\+"        contained contains=phoenixAlias                           skipwhite skipnl
syn match  phoenixCallbackDeclaration    "[^[:space:];#<,()\[\]]\+" contained contains=phoenixFunctionDeclaration             skipwhite skipnl

syn cluster phoenixDeclaration contains=phoenixFunctionDeclaration,phoenixModuleDeclaration,phoenixProtocolDeclaration,phoenixImplDeclaration,phoenixRecordDeclaration,phoenixMacroDeclaration,phoenixDelegateDeclaration,phoenixOverridableDeclaration,phoenixExceptionDeclaration,phoenixCallbackDeclaration,phoenixStructDeclaration

hi def link phoenixDefine                 Define
hi def link phoenixPrivateDefine          Define
hi def link phoenixModuleDefine           String
hi def link phoenixProtocolDefine         String
hi def link phoenixImplDefine             String
hi def link phoenixRecordDefine           Define
hi def link phoenixPrivateRecordDefine    Define
hi def link phoenixMacroDefine            Define
hi def link phoenixPrivateMacroDefine     Define
hi def link phoenixDelegateDefine         Define
hi def link phoenixOverridableDefine      Define
hi def link phoenixExceptionDefine        Define
hi def link phoenixCallbackDefine         Define
hi def link phoenixStructDefine           Define
"hi def link phoenixFunctionDeclaration    Function
hi def link phoenixTypeSig                Identifier
hi def link phoenixMacroDeclaration       Macro
hi def link phoenixInclude                Include
hi def link phoenixComment                Comment
hi def link phoenixTodo                   Todo
hi def link phoenixKeyword                Keyword
hi def link phoenixOperator               Operator
hi def link phoenixAtom                   Constant
hi def link phoenixPseudoVariable         Constant
"hi def link phoenixAlias                  Type
hi def link phoenixBoolean                Boolean
hi def link phoenixVariable               Identifier
"hi def link phoenixSelf                   Identifier
hi def link phoenixUnusedVariable         Comment
hi def link phoenixNumber                 Number
hi def link phoenixDocString              String
hi def link phoenixAtomInterpolated       phoenixAtom
hi def link phoenixRegex                  phoenixString
hi def link phoenixRegexEscape            phoenixSpecial
hi def link phoenixRegexEscapePunctuation phoenixSpecial
hi def link phoenixRegexCharClass         phoenixSpecial
hi def link phoenixRegexQuantifier        phoenixSpecial
hi def link phoenixSpecial                Special
hi def link phoenixString                 String
hi def link phoenixSigil                  String
hi def link phoenixStringDelimiter        Delimiter
hi def link phoenixRegexDelimiter         Delimiter
hi def link phoenixInterpolationDelimiter Delimiter
hi def link phoenixSigilDelimiter         Delimiter
hi def link phoenixLet                    Structure
