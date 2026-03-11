-- JavaServer Pages (JSP) snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

-- Use square brackets as delimiters to avoid conflict with EL ${} and JSP <% %> syntax
local function f(str, nodes)
    return fmt(str, nodes, { delimiters = "[]" })
end

return {
    -- EL Expression
    s("$", f("${[]}", { i(1, "expression") })),
    s("#", f("#{[]} ", { i(1, "expression") })),

    -- JSP Directives
    s("page", f([[<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"[]%>]], { i(1) })),

    s("pageimport", f([[<%@ page import="[]"%>]], { i(1, "java.util.*") })),

    s("include", f([[<%@ include file="[]"%>]], { i(1, "header.jsp") })),

    s("taglib", f([[<%@ taglib prefix="[]" uri="[]"%>]], { i(1, "c"), i(2, "http://java.sun.com/jsp/jstl/core") })),

    s("taglibcore", t([[<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>]])),
    s("taglibfmt", t([[<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>]])),
    s("taglibfn", t([[<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>]])),
    s("taglibform", t([[<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>]])),
    s("taglibspring", t([[<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>]])),

    -- JSP Scriptlet
    s("<%", f([[
<%
    []
%>
]], { i(1) })),

    -- JSP Expression
    s("<%=", f([[<%= [] %>]], { i(1, "expression") })),

    -- JSP Declaration
    s("<%!", f([[
<%!
    []
%>
]], { i(1) })),

    -- JSP Comment
    s("comment", f([[<%-- [] --%>]], { i(1, "comment") })),

    -- JSTL Core Tags
    s("cout", f([[<c:out value="${[]}"[] />]], { i(1, "value"), i(2) })),

    s("cset", f([[<c:set var="[]" value="${[]}"[]/>]], { i(1, "var"), i(2, "value"), i(3) })),

    s("cif", f([[
<c:if test="${[]}">
    []
</c:if>
]], { i(1, "condition"), i(2) })),

    s("cchoose", f([[
<c:choose>
    <c:when test="${[]}">
        []
    </c:when>
    <c:otherwise>
        []
    </c:otherwise>
</c:choose>
]], { i(1, "condition"), i(2), i(3) })),

    s("cwhen", f([[
<c:when test="${[]}">
    []
</c:when>
]], { i(1, "condition"), i(2) })),

    s("cforeach", f([[
<c:forEach var="[]" items="${[]}"[]>
    []
</c:forEach>
]], { i(1, "item"), i(2, "items"), i(3), i(4) })),

    s("cforeachi", f([[
<c:forEach var="[]" items="${[]}" varStatus="[]">
    []
</c:forEach>
]], { i(1, "item"), i(2, "items"), i(3, "status"), i(4) })),

    s("cfortokens", f([[
<c:forTokens var="[]" items="[]" delims="[]">
    []
</c:forTokens>
]], { i(1, "token"), i(2, "${string}"), i(3, ","), i(4) })),

    s("curl", f([[<c:url value="[]"[]/>]], { i(1, "/path"), i(2) })),

    s("curlparam", f([[
<c:url value="[]" var="[]">
    <c:param name="[]" value="${[]}"/>
</c:url>
]], { i(1, "/path"), i(2, "url"), i(3, "param"), i(4, "value") })),

    s("cimport", f([[<c:import url="[]"[]/>]], { i(1, "url"), i(2) })),

    s("credirect", f([[<c:redirect url="[]"/>]], { i(1, "/path") })),

    s("ccatch", f([[
<c:catch var="[]">
    []
</c:catch>
]], { i(1, "exception"), i(2) })),

    -- JSTL Format Tags
    s("fmtdate", f([[<fmt:formatDate value="${[]}" pattern="[]"/>]], { i(1, "date"), i(2, "yyyy-MM-dd") })),

    s("fmtnumber", f([[<fmt:formatNumber value="${[]}" type="[]"[]/>]], { i(1, "number"), i(2, "number"), i(3) })),

    s("fmtcurrency", f([[<fmt:formatNumber value="${[]}" type="currency"/>]], { i(1, "amount") })),

    s("fmtpercent", f([[<fmt:formatNumber value="${[]}" type="percent"/>]], { i(1, "value") })),

    s("fmtmessage", f([[<fmt:message key="[]"/>]], { i(1, "message.key") })),

    s("fmtbundle", f([[
<fmt:bundle basename="[]">
    []
</fmt:bundle>
]], { i(1, "messages"), i(2) })),

    s("fmtsetlocale", f([[<fmt:setLocale value="[]"/>]], { i(1, "en_US") })),

    -- Spring Form Tags
    s("formform", f([[
<form:form modelAttribute="[]" action="[]" method="[]">
    []
    <button type="submit">[]</button>
</form:form>
]], { i(1, "model"), i(2, "/submit"), i(3, "post"), i(4), i(5, "Submit") })),

    s("forminput", f([[<form:input path="[]" cssClass="[]"[]/>]], { i(1, "field"), i(2, "form-control"), i(3) })),

    s("formpassword", f([[<form:password path="[]" cssClass="[]"/>]], { i(1, "password"), i(2, "form-control") })),

    s("formtextarea", f([[<form:textarea path="[]" rows="[]" cssClass="[]"/>]], { i(1, "field"), i(2, "3"), i(3, "form-control") })),

    s("formselect", f([[
<form:select path="[]" cssClass="[]">
    <form:option value="" label="-- Select --"/>
    <form:options items="${[]}" itemValue="[]" itemLabel="[]"/>
</form:select>
]], { i(1, "field"), i(2, "form-control"), i(3, "options"), i(4, "id"), i(5, "name") })),

    s("formcheckbox", f([[<form:checkbox path="[]" value="${[]}"/>]], { i(1, "field"), i(2, "value") })),

    s("formcheckboxes", f([[<form:checkboxes path="[]" items="${[]}" itemValue="[]" itemLabel="[]"/>]], { i(1, "field"), i(2, "options"), i(3, "id"), i(4, "name") })),

    s("formradio", f([[<form:radiobutton path="[]" value="${[]}"/>]], { i(1, "field"), i(2, "value") })),

    s("formradios", f([[<form:radiobuttons path="[]" items="${[]}" itemValue="[]" itemLabel="[]"/>]], { i(1, "field"), i(2, "options"), i(3, "id"), i(4, "name") })),

    s("formerrors", f([[<form:errors path="[]" cssClass="[]"/>]], { i(1, "*"), i(2, "text-danger") })),

    s("formhidden", f([[<form:hidden path="[]"/>]], { i(1, "field") })),

    s("formlabel", f([[<form:label path="[]">[]</form:label>]], { i(1, "field"), i(2, "Label") })),

    -- Spring Tags
    s("springmessage", f([[<spring:message code="[]"/>]], { i(1, "message.code") })),

    s("springurl", f([[<spring:url value="[]" var="[]"/>]], { i(1, "/path"), i(2, "url") })),

    s("springbind", f([[
<spring:bind path="[]">
    []
</spring:bind>
]], { i(1, "path"), i(2) })),

    -- Full JSP Page Template
    s("jsppage", f([[
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>[]</title>
</head>
<body>
    []
</body>
</html>
]], { i(1, "Title"), i(2) })),

    -- JSP with Spring Form
    s("jspform", f([[
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>[]</title>
</head>
<body>
    <form:form modelAttribute="[]" action="[]" method="post">
        []
        <button type="submit">Submit</button>
    </form:form>
</body>
</html>
]], { i(1, "Form"), i(2, "model"), i(3, "/submit"), i(4) })),

    -- EL Functions
    s("fnlength", f("${fn:length([])}", { i(1, "collection") })),
    s("fncontains", f("${fn:contains([], '[]')}", { i(1, "string"), i(2, "search") })),
    s("fnsubstring", f("${fn:substring([], [], [])}", { i(1, "string"), i(2, "0"), i(3, "10") })),
    s("fnreplace", f("${fn:replace([], '[]', '[]')}", { i(1, "string"), i(2, "old"), i(3, "new") })),
    s("fnsplit", f("${fn:split([], '[]')}", { i(1, "string"), i(2, ",") })),
    s("fnjoin", f("${fn:join([], '[]')}", { i(1, "array"), i(2, ",") })),
    s("fntrim", f("${fn:trim([])}", { i(1, "string") })),
    s("fnupper", f("${fn:toUpperCase([])}", { i(1, "string") })),
    s("fnlower", f("${fn:toLowerCase([])}", { i(1, "string") })),

    -- Common patterns
    s("empty", f([[
<c:if test="${empty []}">
    []
</c:if>
]], { i(1, "variable"), i(2, "Variable is empty") })),

    s("notempty", f([[
<c:if test="${not empty []}">
    []
</c:if>
]], { i(1, "variable"), i(2) })),

    s("ternary", f("${([]) ? '[]' : '[]'}", { i(1, "condition"), i(2, "true"), i(3, "false") })),
}
