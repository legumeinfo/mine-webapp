<%@ page import="org.biojava.nbio.core.sequence.io.FastaWriterHelper" %>
<%@ page import="org.ncgr.intermine.web.logic.SequenceBlastUtil" %>
<%
try {
    // Display the BLAST button to send the sequence to the SequenceServer
    Integer objectId = Integer.parseInt(request.getParameter("id"));
    SequenceBlastUtil sequenceBlastUtil = new SequenceBlastUtil(request, objectId);
    if (sequenceBlastUtil.getBioSequence()!=null) {
        String fasta = sequenceBlastUtil.getFasta();
%>
<form class="small-button" action="${WEB_PROPERTIES['sequenceserver.url']}" method="post" target="_blank">
    <input type="hidden" name="input_sequence" value="<%=fasta%>" />
    <button type="submit">BLAST</button>
</form>
<%
    }
} catch (Exception ex) {
    // do nothing on keyword search result
}
%>
