<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.intermine.api.query.PathQueryExecutor,org.intermine.api.results.ExportResultsIterator,org.intermine.api.results.ResultElement" %>
<%@ page import="org.intermine.pathquery.Constraints, org.intermine.pathquery.OrderDirection, org.intermine.pathquery.PathQuery" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.Map, java.util.LinkedHashMap, java.util.List, java.util.LinkedList" %>
<%
// output JSON map
Map<String,Object> jsonMap = new LinkedHashMap<String,Object>();

// get requested marker
String markerName = request.getParameter("markerName");
if (markerName==null) {
    jsonMap.put("error", "markerName missing in markerJSON request.");
    JSONObject json = new JSONObject(jsonMap);
    json.write(response.getWriter());
    return;
}

// initialize
InterMineAPI im = SessionMethods.getInterMineAPI(session);
Profile user = SessionMethods.getProfile(session);
PathQueryExecutor executor = im.getPathQueryExecutor(user);

try {

    ExportResultsIterator iterator;
    
    // query QTLs for requested marker (if any)
    List<String> qtls = new LinkedList<String>();
    List<String> traits = new LinkedList<String>();
    PathQuery qtlQuery = new PathQuery(im.getModel());
    qtlQuery.addViews(
        "GeneticMarker.qtls.identifier",
        "GeneticMarker.qtls.trait.primaryIdentifier"
    );
    qtlQuery.addConstraint(Constraints.eq("GeneticMarker.primaryIdentifier", markerName));
    qtlQuery.addOrderBy("GeneticMarker.qtls.identifier", OrderDirection.ASC);
    iterator = executor.execute(qtlQuery);
    while (iterator.hasNext()) {
        List<ResultElement> results = iterator.next();
        qtls.add((String) results.get(0).getField());
        traits.add((String) results.get(1).getField());
    }

    // query linkage group positions for requested marker (if any)
    List<String> linkageGroups = new LinkedList<String>();
    List<Double> positions = new LinkedList<Double>();
    PathQuery lgQuery = new PathQuery(im.getModel());
    lgQuery.addViews(
        "GeneticMarker.linkageGroupPositions.linkageGroup.identifier",
        "GeneticMarker.linkageGroupPositions.position"
    );
    lgQuery.addConstraint(Constraints.eq("GeneticMarker.primaryIdentifier", markerName));
    lgQuery.addOrderBy("GeneticMarker.linkageGroupPositions.linkageGroup.identifier", OrderDirection.ASC);
    iterator = executor.execute(lgQuery);
    while (iterator.hasNext()) {
        List<ResultElement> results = iterator.next();
        linkageGroups.add((String) results.get(0).getField());
        positions.add(new Double(results.get(1).getField()));
    }

    // create the JSON response using the Map to JSON utility
    jsonMap.put("linkageGroups", linkageGroups);
    jsonMap.put("positions", positions);
    jsonMap.put("qtls", qtls);
    jsonMap.put("traits", traits);

} catch (Exception ex) {

    jsonMap.put("error", ex.toString());

}

// write the JSON to the response
try {
    JSONObject json = new JSONObject(jsonMap);
    json.write(response.getWriter());
} catch (Exception ex) {
    throw new RuntimeException(ex);
}
%>
