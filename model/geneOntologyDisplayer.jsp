<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/string-1.1" prefix="str" %>


<!-- geneOntologyDisplayer.jsp -->
<div class="basic-table">
    <h3>Gene Ontology</h3>

    <c:choose>
        <c:when test="${!empty noGoMessage }">
            <p>${noGoMessage}</p>
        </c:when>
        <c:otherwise>
            <c:choose>
	        <c:when test="${!empty goTerms}">
	            <c:forEach items="${goTerms}" var="parentEntry">
		        <c:set var="parentTerm" value="${parentEntry.key}" />
		        <div style="padding-top:5px;padding-left:6px;">
                            <b>${parentTerm}</b><br/>
                            <c:choose>
		                <c:when test="${empty parentEntry.value}">
                                    <i>No terms in this category.</i>
			        </c:when>
			        <c:otherwise>
			            <c:forEach items="${parentEntry.value}" var="entry">
			                <c:set var="term" value="${entry.key}" />
			                <html:link href="/${WEB_PROPERTIES['webapp.path']}/report.do?id=${term.id}" title="${term.description}">
                                            <c:out value="${term.name}"/>
                                        </html:link>
                                        <im:helplink text="${term.description}"/>
                                        &nbsp;
			            </c:forEach>
			        </c:otherwise>
			    </c:choose>
                        </div>
		    </c:forEach>
		</c:when>
		<c:otherwise>
		    <p style="font-style:italic;">No results</p>
		</c:otherwise>
	    </c:choose>
        </c:otherwise>
    </c:choose>
</div>
<!-- /geneOntologyDisplayer.jsp -->
