" Vim syntax file
" Language: JavaServer Pages (JSP)
" Maintainer: pvim
" Latest Revision: 2024

if exists("b:current_syntax")
    finish
endif

" Load HTML syntax first
runtime! syntax/html.vim
unlet! b:current_syntax

" JSP directives <%@ ... %>
syn region jspDirective matchgroup=jspDelimiter start="<%@" end="%>" contains=jspDirectiveKeyword,jspAttribute,jspString
syn keyword jspDirectiveKeyword contained page include taglib

" JSP declarations <%! ... %>
syn region jspDeclaration matchgroup=jspDelimiter start="<%!" end="%>" contains=@javaTop

" JSP scriptlets <% ... %>
syn region jspScriptlet matchgroup=jspDelimiter start="<%" end="%>" contains=@javaTop

" JSP expressions <%= ... %>
syn region jspExpression matchgroup=jspDelimiter start="<%=" end="%>" contains=@javaTop

" JSP comments <%-- ... --%>
syn region jspComment start="<%--" end="--%>"

" EL expressions ${...} and #{...}
syn region jspEL matchgroup=jspELDelimiter start="\${" end="}" contains=jspELVar,jspELString,jspELOperator,jspELNumber,jspELKeyword
syn region jspEL matchgroup=jspELDelimiter start="#{" end="}" contains=jspELVar,jspELString,jspELOperator,jspELNumber,jspELKeyword

" EL contents
syn match jspELVar contained "\w\+\(\.\w\+\)*"
syn match jspELOperator contained "[+\-*/%=<>!&|?:]"
syn match jspELOperator contained "&&\|||"
syn match jspELOperator contained "\.\."
syn region jspELString contained start='"' end='"' skip='\\"'
syn region jspELString contained start="'" end="'" skip="\\'"
syn match jspELNumber contained "\d\+"
syn keyword jspELKeyword contained and or not eq ne lt gt le ge empty div mod true false null

" JSTL core tags
syn region jspTag matchgroup=jspTagDelimiter start="<c:" end=">" contains=jspTagName,jspAttribute,jspString,jspEL
syn region jspTag matchgroup=jspTagDelimiter start="</c:" end=">"
syn keyword jspTagName contained if choose when otherwise forEach forTokens
syn keyword jspTagName contained set remove out catch import url redirect param

" JSTL fmt tags
syn region jspTag matchgroup=jspTagDelimiter start="<fmt:" end=">" contains=jspFmtTagName,jspAttribute,jspString,jspEL
syn region jspTag matchgroup=jspTagDelimiter start="</fmt:" end=">"
syn keyword jspFmtTagName contained message formatNumber formatDate parseNumber parseDate
syn keyword jspFmtTagName contained setLocale setBundle bundle setTimeZone timeZone requestEncoding

" JSTL sql tags
syn region jspTag matchgroup=jspTagDelimiter start="<sql:" end=">" contains=jspSqlTagName,jspAttribute,jspString,jspEL
syn region jspTag matchgroup=jspTagDelimiter start="</sql:" end=">"
syn keyword jspSqlTagName contained query update transaction setDataSource param dateParam

" Spring form tags
syn region jspTag matchgroup=jspTagDelimiter start="<form:" end=">" contains=jspFormTagName,jspAttribute,jspString,jspEL
syn region jspTag matchgroup=jspTagDelimiter start="</form:" end=">"
syn keyword jspFormTagName contained form input hidden password text textarea
syn keyword jspFormTagName contained checkbox checkboxes radiobutton radiobuttons select option options
syn keyword jspFormTagName contained errors label button

" Attributes
syn match jspAttribute contained "\w\+=" contains=jspAttributeName
syn match jspAttributeName contained "\w\+"
syn region jspString contained start='"' end='"' skip='\\"' contains=jspEL
syn region jspString contained start="'" end="'" skip="\\'" contains=jspEL

" Include Java syntax for scriptlets
syn include @javaTop syntax/java.vim

" Highlighting
hi def link jspDelimiter Special
hi def link jspDirective PreProc
hi def link jspDirectiveKeyword Keyword
hi def link jspDeclaration PreProc
hi def link jspScriptlet PreProc
hi def link jspExpression PreProc
hi def link jspComment Comment
hi def link jspEL Identifier
hi def link jspELDelimiter Special
hi def link jspELVar Identifier
hi def link jspELString String
hi def link jspELNumber Number
hi def link jspELOperator Operator
hi def link jspELKeyword Keyword
hi def link jspTag Statement
hi def link jspTagDelimiter Special
hi def link jspTagName Function
hi def link jspFmtTagName Function
hi def link jspSqlTagName Function
hi def link jspFormTagName Function
hi def link jspAttribute Type
hi def link jspAttributeName Type
hi def link jspString String

let b:current_syntax = "jsp"
