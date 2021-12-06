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
<table class="annotation">
<% for (String geneFamilyIdentifier : multiFastaMap.keySet()) { %>
    <tr>
        <td>
            <form action="${WEB_PROPERTIES['annotate.url']}" method="post" style="display:inline;border:0;margin:0;padding:0;" target="_blank">
                <input type="hidden" name="type" value="<%=sequenceType%>" />
                <input type="hidden" name="geneFamily" value="<%=geneFamilyIdentifier%>" />
                <input type="hidden" name="fasta" value="<%=multiFastaMap.get(geneFamilyIdentifier)%>" />
                <button type="submit" style="border:0;margin:0;padding:0;"><img src="model/images/annotate.png" title="ANNOTATE"/></button>
            </form>
        </td>
        <td><%=countMap.get(geneFamilyIdentifier)%> sequence(s)</td>
        <td><b><%=geneFamilyIdentifier%></b></td>
        <td><%=geneFamilyDescriptionMap.get(geneFamilyIdentifier)%></td>
    </tr>
<% } %>
</table>
<!-- /annotation.jsp -->
