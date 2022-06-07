<%
// Display the FASTA button
try {
Integer objectId = Integer.parseInt(request.getParameter("id"));
%>
<form class="small-button" action="sequenceExporter.do" method="get" target="_blank">
    <input type="hidden" name="object" value="<%=objectId%>" />
    <button type="submit">FASTA</button>
</form>
<%
} catch (Exception ex) {
    // do nothing on keyword search results
}
%>
