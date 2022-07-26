" Vim syntax file for marsh
" Language:    marsh
" Maintainer:  Søren Mortensen <soren@neros.dev>
" Last Change: 31 Mar 2022

" if exists("b:current_syntax")
"     finish
" endif

syn keyword marshConditional if else
syn keyword marshRepeat while

syn keyword marshKeyword fn nextgroup=marshFuncName skipwhite skipempty

syn match marshIdent "[a-z_][a-z0-9_']*" display contained
syn match marshFuncName "[a-z_][a-z0-9_']*" display contained
syn match marshType "[A-Z][a-zA-Z0-9]*" display contained

syn match marshLocation display "'[a-z][a-z0-9_]*"

syn match marshDecNumber display "[0-9]\+"
syn match marshHexNumber display "0x[a-fA-F0-9]\+"
syn match marshOctNumber display "0o[0-7_]\+"
syn match marshBinNumber display "0b[01]\+"

syn keyword marshType Int String Bool Path

syn keyword marshBoolean true false

syn match marshOperator display "\%(+\|-\|/\|*\)"
syn match marshSigil display "\."

syn match marshDoubleColon "::"
syn match marshThinArrow "->"
syn match marshFatArrow "=>"

syn match marshFuncCall "@[a-z_][a-z0-9_']*"
syn match marshFuncCall "@[a-z_][a-z0-9_']*::("he=e-3,me=e-3
syn match marshFuncCall "@("he=e-1,me=e-1

" syn match marshPath "\.\.?/([^/]\+/)*[^/]\+\.[^/]\+"
syn match marshPath "\.\.\?/\([^/]\+/\)*[^/]\+\.[^/]\+"

syn region marshCommentLine start="#" end="$"
syn region marshString matchgroup=marshStringDelimiter start=+"+ end=+"+

hi def link marshKeyword Keyword

hi def link marshConditional Conditional
hi def link marshRepeat Conditional
hi def link marshIdent Identifier
hi def link marshFuncName Function
hi def link marshType Type

hi def link marshLocation Special

hi def link marshBinNumber marshNumber
hi def link marshOctNumber marshNumber
hi def link marshDecNumber marshNumber
hi def link marshHexNumber marshNumber

hi def link marshNumber Number

hi def link marshString String
hi def link marshStringDelimiter String

hi def link marshPath String

hi def link marshFuncCall Function

hi def link marshDoubleColon marshOperator
hi def link marshThinArrow marshOperator
hi def link marshFatArrow marshOperator
hi def link marshOperator Operator
hi def link marshSigil Operator

hi def link marshCommentLine Comment

let b:current_syntax = "marsh"
