" Vim syntax file
" Language: FreeMarker Template Language
" Maintainer: pvim
" Latest Revision: 2024

if exists("b:current_syntax")
    finish
endif

" Load HTML syntax first
runtime! syntax/html.vim
unlet! b:current_syntax

" FreeMarker directives
syn region ftlDirective matchgroup=ftlDelimiter start="<#" end=">" contains=ftlKeyword,ftlString,ftlVariable,ftlOperator,ftlNumber
syn region ftlDirective matchgroup=ftlDelimiter start="</#" end=">" contains=ftlKeyword
syn region ftlComment start="<#--" end="-->"

" FreeMarker interpolation ${...}
syn region ftlInterpolation matchgroup=ftlDelimiter start="\${" end="}" contains=ftlVariable,ftlString,ftlOperator,ftlNumber,ftlBuiltin
syn region ftlInterpolation matchgroup=ftlDelimiter start="#{" end="}" contains=ftlVariable,ftlString,ftlOperator,ftlNumber

" FreeMarker keywords
syn keyword ftlKeyword contained if else elseif list as switch case default break
syn keyword ftlKeyword contained include import macro nested return local global
syn keyword ftlKeyword contained assign attempt recover ftl noparse compress escape
syn keyword ftlKeyword contained noescape function flush stop visit recurse fallback
syn keyword ftlKeyword contained setting items sep

" FreeMarker built-ins (after ?)
syn match ftlBuiltin contained "?\w\+" contains=ftlBuiltinName
syn keyword ftlBuiltinName contained string number date time datetime boolean
syn keyword ftlBuiltinName contained size length has_content exists is_string is_number
syn keyword ftlBuiltinName contained upper_case lower_case cap_first uncap_first trim
syn keyword ftlBuiltinName contained html xml js json url c eval has_next index
syn keyword ftlBuiltinName contained first last sort sort_by reverse join split
syn keyword ftlBuiltinName contained replace matches groups substring contains
syn keyword ftlBuiltinName contained starts_with ends_with index_of last_index_of

" FreeMarker variables and operators
syn match ftlVariable contained "\w\+\(\.\w\+\)*"
syn match ftlOperator contained "[+\-*/%=<>!&|?:]"
syn match ftlOperator contained "\.\."
syn match ftlOperator contained "&&\|||"
syn match ftlOperator contained "??"
syn region ftlString contained start='"' end='"' skip='\\"'
syn region ftlString contained start="'" end="'" skip="\\'"
syn match ftlNumber contained "\d\+"
syn match ftlNumber contained "\d\+\.\d\+"

" Highlighting
hi def link ftlDelimiter Special
hi def link ftlDirective PreProc
hi def link ftlKeyword Keyword
hi def link ftlComment Comment
hi def link ftlInterpolation Identifier
hi def link ftlVariable Identifier
hi def link ftlString String
hi def link ftlNumber Number
hi def link ftlOperator Operator
hi def link ftlBuiltin Function
hi def link ftlBuiltinName Function

let b:current_syntax = "ftl"
