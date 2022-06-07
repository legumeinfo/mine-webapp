<!-- annotation.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<html:xhtml />
<tiles:importAttribute />
<%
// server-side variables
if (request.getAttribute("errorMessage")!=null) {
    out.print("<code>"+request.getAttribute("errorMessage")+"</code>");
    return;
}
// request attributes from AnnotationController.java
String sequenceType = (String) request.getAttribute("sequenceType");
java.util.Map<String,Integer> countMap = (java.util.Map<String,Integer>) request.getAttribute("countMap");
java.util.Map<String,String> multiFastaMap = (java.util.Map<String,String>) request.getAttribute("multiFastaMap");
java.util.Map<String,String> geneFamilyDescriptionMap = (java.util.Map<String,String>) request.getAttribute("geneFamilyDescriptionMap");
%>
<h3>Submit sequences per gene family to the annotation pipeline:</h3>
<%
for (String geneFamilyIdentifier : multiFastaMap.keySet()) {
    // HACK: only show gene families that start with "legfed"
    if (geneFamilyIdentifier.startsWith("legfed")) {
%>
    <div class="annotation">
        <form class="small-button" action="${WEB_PROPERTIES['annotate.url']}" method="post" target="_blank">
            <input type="hidden" name="type" value="<%=sequenceType%>" />
            <input type="hidden" name="geneFamily" value="<%=geneFamilyIdentifier%>" />
            <input type="hidden" name="fasta" value="<%=multiFastaMap.get(geneFamilyIdentifier)%>" />
            <button type="submit"><%=geneFamilyIdentifier%></button>
        </form>
        <%=countMap.get(geneFamilyIdentifier)%> sequence(s):
        <%=geneFamilyDescriptionMap.get(geneFamilyIdentifier)%>
    </div>
<%
}
}
%>
</table>
<!-- /annotation.jsp -->
