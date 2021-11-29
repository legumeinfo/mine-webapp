<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im" %>
<!-- sequenceShortDisplayerWithField.jsp -->
<tiles:importAttribute name="expr" ignore="false"/>
<im:eval evalExpression="interMineObject.${expr}" evalVariable="outVal"/>
<c:choose>
    <c:when test="${empty outVal}">
        &nbsp;
    </c:when>
    <c:otherwise>
        <c:choose>
            <c:when test="${!empty interMineObject.sequence}">
                <im:value>${outVal}</im:value>&nbsp;
                <html:link action="sequenceExporter?object=${interMineObject.id}" target="_blank"><html:img styleClass="fasta" src="model/images/fasta.gif" title="FASTA"/></html:link>
                <c:if test="${!empty WEB_PROPERTIES['sequenceserver.url']}">
                    <jsp:include page="sequenceServerBlastButton.jsp"/>
                </c:if>
                <c:if test="${!empty WEB_PROPERTIES['funnotate.url']}">
                    <jsp:include page="funnotateButton.jsp"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <im:value>${outVal}</im:value>
            </c:otherwise>
        </c:choose>
    </c:otherwise>
</c:choose>
<!-- /sequenceShortDisplayerWithField.jsp -->
