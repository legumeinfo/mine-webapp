<!-- markerAlleleInfo.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="org.intermine.model.InterMineObject,org.intermine.model.bio.SequenceFeature" %>
<%@ page import="org.intermine.bio.web.biojava.BioSequence,org.intermine.bio.web.biojava.BioSequenceFactory,org.intermine.bio.web.biojava.BioSequenceFactory.SequenceType" %>
<%@ page import="java.util.Map,java.util.HashMap,java.net.URLEncoder,java.text.NumberFormat" %>
<html:xhtml />
<tiles:importAttribute />
<%
NumberFormat percFormat = NumberFormat.getPercentInstance();

// url to link genotyping study report
String genotypingStudyURL = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getServletContext().getContextPath()+"/portal.do?class=GenotypingStudy&externalids=";

// the genotyping studies containing this marker, along with lines and values in their own map
SequenceFeature marker = (SequenceFeature) request.getAttribute("marker");
Map<String,Map<String,String>> genotypingStudyMap = (Map<String,Map<String,String>>) request.getAttribute("genotypingStudyMap");
Map<String,String> genotypingStudyDescriptions = (Map<String,String>) request.getAttribute("genotypingStudyDescriptions");
Map<String,String> genotypingStudyMatrixNotes = (Map<String,String>) request.getAttribute("genotypingStudyMatrixNotes");

// get the reference allele from this marker's chromosome location
BioSequence bioSequence = BioSequenceFactory.make(marker, SequenceType.DNA);
String refAllele = bioSequence.getSequenceAsString();
%>
<div id="marker-info-displayer" class="collection-table column-border-by-2">
    <h3>Allele statistics</h3>
    <%
    // calculate some allele stats
    for (String genotypingStudyName : genotypingStudyMap.keySet()) {
        String genotypingStudyDescription = genotypingStudyDescriptions.get(genotypingStudyName);
        Map<String,String> valuesMap = genotypingStudyMap.get(genotypingStudyName);
        Map<String,Integer> countMap = new HashMap<String,Integer>();
        Map<String,Double> percMap = new HashMap<String,Double>();
        for (String line : valuesMap.keySet()) {
            String value = valuesMap.get(line);
            if (countMap.containsKey(value)) {
                int count = countMap.get(value) + 1;
                countMap.put(value, count);
            } else {
                countMap.put(value, 1);
            }
        }
        // get the percentages
        int countTotal = 0;
        for (String value : countMap.keySet()) {
            countTotal += countMap.get(value);
        }
        for (String value : countMap.keySet()) {
            percMap.put(value, (double)countMap.get(value)/(double)countTotal);
        }
    %>
    <div style="padding:7px;">
        <b>Genotyping Study:</b> <a href="<%=genotypingStudyURL+URLEncoder.encode(genotypingStudyName,"UTF-8")%>"><b><%=genotypingStudyName%></b></a>
        <p><%=genotypingStudyDescription%></p>
    </div>
    <table>
        <tr>
            <td>Allele (<b>bold</b>=reference)</td>
            <% for (String value : countMap.keySet()) { %>
                <td><% if (value.toLowerCase().equals(refAllele.toLowerCase())) out.print("<b>"+value+"</b>"); else out.print(value); %></td>
            <% } %>
        </tr>
        <tr>
            <td>Count</td>
            <% for (String value : countMap.keySet()) { %>
                <td><% if (value.toLowerCase().equals(refAllele.toLowerCase())) out.print("<b>"+countMap.get(value)+"</b>"); else out.print(countMap.get(value)); %></td>
            <% } %>
        </tr>
        <tr>
            <td>Fraction</td>
            <% for (String value : countMap.keySet()) { %>
                <td><% if (value.toLowerCase().equals(refAllele.toLowerCase())) out.print("<b>"+percFormat.format(percMap.get(value))+"</b>"); else out.print(percFormat.format(percMap.get(value))); %></td>
            <% } %>
        </tr>
    </table>
<%
} // loop over genotyping studies
%>
</div>
<!-- /markerAlleleInfo.jsp -->
