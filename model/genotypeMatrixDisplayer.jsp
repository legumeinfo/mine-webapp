<!-- genotypeMatrixDisplayer.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.util.List" %>
<%@ page import="org.intermine.api.InterMineAPI,org.intermine.api.bag.BagManager,org.intermine.api.profile.Profile,org.intermine.api.profile.InterMineBag" %>
<%@ page import="org.intermine.web.logic.session.SessionMethods" %>
<html:xhtml />
<tiles:importAttribute />
<!-- web.properties constants -->
<c:set var="genotypingRecordLength" value="${WEB_PROPERTIES['genotypeMatrixDisplayer.genotypingRecordLength']}"/>
<c:set var="genotypingRecordAdvance" value="${WEB_PROPERTIES['genotypeMatrixDisplayer.genotypingRecordAdvance']}"/>
<%
// request data from GenotypeMatrixDisplayer
String studyPrimaryIdentifier = (String) request.getAttribute("studyPrimaryIdentifier");
List<String> chrNames = (List<String>) request.getAttribute("chrNames");

// list names for filtering
// NOT IN USE
// String sampleSortName = request.getParameter("sampleSortName");
// String sampleListName = request.getParameter("sampleListName");
// String genotypingRecordListName = request.getParameter("genotypingRecordListName");
// if (sampleSortName==null) sampleSortName = "";
// if (sampleListName==null) sampleListName = "";
// if (genotypingRecordListName==null) genotypingRecordListName = "";
// get the appropriate lists
// NOT IN USE
// Map<String,InterMineBag> bags;
// Map<String,InterMineBag> sampleBags = new HashMap<>();
// Map<String,InterMineBag> genotypingRecordBags = new HashMap<>();
// final InterMineAPI im = SessionMethods.getInterMineAPI(session);
// Profile user = SessionMethods.getProfile(session);
// BagManager bm = im.getBagManager();
// bags = bm.getBags(user);
// for (String bagName : bags.keySet()) {
//     InterMineBag bag = bags.get(bagName);
//     if (bag.getType().equals("Sample")) sampleBags.put(bagName, bag);
//     if (bag.getType().equals("VCFRecord")) genotypingRecordBags.put(bagName, bag);
// }
%>
<style>
table.dataTable thead th {
    padding-top: 4px;
    padding-bottom: 4px;
    font-size: 8px;
    color: black;
    background-color: white;
}
table.dataTable tbody td {
    padding-top: 4px;
    padding-bottom: 4px;
    font-size: 8px;
    color: white;
}
table.dataTable.no-footer {
    border-bottom: 0;
    margin-bottom: 5px;
}
.dt-center {
    width: ${100.0/(genotypingRecordLength+1)}%;
    font-size: 8px;
    font-weight: bold;
} 
.dt-buttons {
    margin-top: 2px;
    margin-left: 50px;
}
.dt-button {
}
.dataTables_info {
    padding: 0 5px 0 0;
}

.b { font-weight: bold; }
.ar { text-align: right; }
.al { text-align: left; }

.sample { background-color: white; color: black; font-size: 8px; font-weight: bold;}
.sample a { text-decoration: none; color: black; }

.jumpForm { width: 300px; position: absolute; left: 200px; display: inline-block; z-index: 2; }
.jumpForm select { }
.jumpForm button { background-color: yellow; }

#genotypes_wrapper {
    top: 0px;
}
#progressIndicator {
    z-index: 3;
    position: absolute;
    top: -80px;
    left: 400px;
    opacity: 0.6;
}
</style>

<script type="text/javascript">
 var studyPrimaryIdentifier = '<%=studyPrimaryIdentifier%>';
 var chrName = '<%=chrNames.get(0)%>';
 var genotypingRecordLength = ${genotypingRecordLength};
 var genotypingRecordAdvance = ${genotypingRecordAdvance};
 var genotypingRecordAdvanceDefault = ${genotypingRecordAdvance};
 var genotypingRecordStart = 0;
 var orderColumn = 0;
 var orderDir = "asc";
 var genotypingRecordCount = 0;
</script>

<div id="progressIndicator"><img src="model/images/xopreload.gif"/></div>

<div class="jumpForm">
    Chr:
    <select id="jumpTo">
        <% for (String chr : chrNames) { %>
            <option><%=chr%></option>
        <% } %>
    </select>
</div>
<table id="genotypes" class="cell-border" style="width:100%">
  <thead>
    <tr>
      <th>Sample</th>
      <c:forEach var="i" begin="1" end="${genotypingRecordLength}" varStatus="loop">
        <th><c:out value="${i}"/></th>
      </c:forEach>
    </tr>
  </thead>
</table>

<script type="text/javascript">
$(document).ready(function() {
    var table = $('#genotypes').DataTable({
        "dom": "lfrtipB",
        "paging": true,
        "deferRender": false,
        "serverSide": true,
        "scrollX": true,
        "autoWidth": false,
        "pagingType": "simple_numbers",
        "ordering": true,
        "searching": false,
        "pageLength": 10,
        "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
        "language": {
            "lengthMenu": 'Show _MENU_ samples',
            "paginate": {
                "previous": 'Previous samples',
                "next": 'Next samples'
            }
        },
        "columnDefs": [
            {
                "targets": [0],
                "className": 'sample ar',
            },
            // 10-color qualitative
            // ['#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a']
            {
                "targets": '_all',
                "className": 'dt-center',
                "createdCell": function (td, cellData, rowData, row, col) {
                    if (cellData=='A' || cellData=='a' || cellData=='A/A' || cellData=='a/a') {
                        $(td).css("background-color", "#e31a1c");
                    } else if (cellData=='C' || cellData=='c' || cellData=='C/C' || cellData=='c/c') {
                        $(td).css("background-color", "#1f78b4");
                    } else if (cellData=='G' || cellData=='g' || cellData=='G/G' || cellData=='g/g' || cellData=='B' || cellData=='b') {
                        $(td).css("background-color", "#33a02c");
                    } else if (cellData=='T' || cellData=='t' || cellData=='T/T' || cellData=='t/t') {
                        $(td).css("background-color", "#6a3d9a");
                    } else if (cellData=='A/C' || cellData=='C/A') {
                        $(td).css("background-color", "#b2df8a");
                    } else if (cellData=='A/G' || cellData=='G/A' || cellData=='X' || cellData=='x') {
                        $(td).css("background-color", "#cab2d6");
                    } else if (cellData=='A/T' || cellData=='T/A') {
                        $(td).css("background-color", "#fb9a99");
                    } else if (cellData=='C/G' || cellData=='G/C') {
                        $(td).css("background-color", "#a6cee3");
                    } else if (cellData=='C/T' || cellData=='T/C') {
                        $(td).css("background-color", "#fdbf6f");
                    } else if (cellData=='G/T' || cellData=='T/G') {
                        $(td).css("background-color", "#ff7f00");
                    } else if (cellData=='./.' || cellData=='U') {
                        $(td).css("background-color", "gray");
                    } else {
                        $(td).css("color", "black");
                        $(td).css("background-color", "white");
                    }
                }
            }
        ],
        "ajax": {
            url: 'model/genotypeMatrixJSON.jsp',
            type: 'POST',
            data: {
                "studyPrimaryIdentifier": function() { return studyPrimaryIdentifier; },
                "chrName": function() { return chrName; },
                "genotypingRecordLength": function() { return genotypingRecordLength; },
                "genotypingRecordStart":  function() { return genotypingRecordStart; },
                "genotypingRecordAdvance": function() { return genotypingRecordAdvance; },
                "orderColumn": function() { return orderColumn; },
                "orderDir": function() { return orderDir; },
            }
        },
        "headerCallback": function(thead, data, start, end, display) {
            $("#progressIndicator").toggle();
            $.ajax({
                url: "model/genotypeMatrixJSON.jsp",
                data: {
                    "isHeaderQuery": true,
                    "studyPrimaryIdentifier": function() { return studyPrimaryIdentifier; },
                    "chrName": function() { return chrName; },
                    "genotypingRecordLength": function() { return genotypingRecordLength; },
                    "genotypingRecordStart":  function() { return genotypingRecordStart; },
                    "genotypingRecordAdvance": function() { return genotypingRecordAdvance; },
                    "orderColumn": function() { return orderColumn; },
                    "orderDir": function() { return orderDir; },
                },
                success: function(result) {
                    genotypingRecordCount = result.genotypingRecordCount;
                    for (var i=0; i<result.header.length; i++) {
                        $(thead).find('th').eq(i+1).html(result.header[i]);
                    }
                    $("#progressIndicator").toggle();
                }
            });
        },
        "buttons": {
            "buttons": [
                {
                    "text": "&larr; 100k",
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = -100000;
                        if (genotypingRecordStart+genotypingRecordAdvance>=0) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("Less than 10k records in reverse direction.");
                        }
                    }
                },
                {
                    "text": "&larr; 10k",
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = -10000;
                        if (genotypingRecordStart+genotypingRecordAdvance>=0) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("Less than 10k records in reverse direction.");
                        }
                    }
                },
                {
                    "text": "&larr; 1k",
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = -1000;
                        if (genotypingRecordStart+genotypingRecordAdvance>=0) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("Less than 1k records in reverse direction.");
                        }
                    }
                },
                {
                    "text": "&larr; 100",
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = -100;
                        if (genotypingRecordStart+genotypingRecordAdvance>=0) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("Less than 100 records in reverse direction.");
                        }
                    }
                },
                {
                    "text": "&larr; "+genotypingRecordAdvanceDefault,
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = -genotypingRecordAdvanceDefault;
                        if (genotypingRecordStart+genotypingRecordAdvance>=0) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("No more records in reverse direction.");
                        }
                    }
                },
                {
                    "text": genotypingRecordAdvanceDefault+" &rarr;",
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = +genotypingRecordAdvanceDefault;
                        if (genotypingRecordStart+genotypingRecordAdvance<genotypingRecordCount) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("No more records in forward direction.");
                        }
                    }
                },
                {
                    "text": "100 &rarr;",
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = +100;
                        if (genotypingRecordStart+genotypingRecordAdvance<genotypingRecordCount) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("Less than 100 records in forward direction.");
                        }
                    }
                },
                {
                    "text": "1k &rarr;",
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = +1000;
                        if (genotypingRecordStart+genotypingRecordAdvance<genotypingRecordCount) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("Less than 1k records in forward direction.");
                        }
                    }
                },
                {
                    "text": "10k &rarr;",
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = +10000;
                        if (genotypingRecordStart+genotypingRecordAdvance<genotypingRecordCount) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("Less than 10k records in forward direction.");
                        }
                    }
                },
                {
                    "text": "100k &rarr;",
                    "action": function (e, dt, node, config) {
                        genotypingRecordAdvance = +100000;
                        if (genotypingRecordStart+genotypingRecordAdvance<genotypingRecordCount) {
                            genotypingRecordStart += genotypingRecordAdvance;
                            dt.ajax.reload();
                        } else {
                            alert("Less than 10k records in forward direction.");
                        }
                    }
                }
            ]
        }
    });
    
    table.on('preXhr', function() {
        $("#progressIndicator").toggle();
        var order = table.order()[0];
        orderColumn = order[0];
        orderDir = order[1];
    });
    
    table.on('xhr', function() {
        $("#progressIndicator").toggle();
        var order = table.order()[0];
        orderColumn = order[0];
        orderDir = order[1];
    });
    
    table.on('order.dt', function () {
        var order = table.order()[0];
        orderColumn = order[0];
        orderDir = order[1];
    });
    
    table.on('draw.dt', function () {
        var order = table.order()[0];
        orderColumn = order[0];
        orderDir = order[1];
    });
     
     $('#jumpTo').on('change', function() {
         chrName = $('#jumpTo').val();
         genotypingRecordStart = 0;
         table.ajax.reload();
     });
});
</script>
<!-- /genotypeMatrixDisplayer.jsp -->
