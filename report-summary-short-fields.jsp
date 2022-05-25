                <%-- summary short fields --%>
                <table class="fields">
                    <c:set var="tableCount" value="0" scope="page" />

                    <c:forEach var="field" items="${object.objectSummaryFields}">
                        <%-- Expose useful props to the js --%>
                        <%-- <script>alert("TEST");</script> --%>
                        <%-- <script> imSummaryFields["${field.name}"] = "${field.value}";</script> --%>
                        <script> imSummaryFields["${field.name}"] = "${fn:replace(field.value, newLineChar, "; ")}";</script>

                        <tr>
                        <c:set var="fieldDisplayText"
                               value="${imf:formatFieldChain(field.pathString, INTERMINE_API, WEBCONFIG)}"/>
                        <c:choose>
                            <c:when test="${field.valueHasDisplayer}">
                                <td class="label">${fieldDisplayText}<im:typehelp type="${field.pathString}"/></td>
                                <td>
                                    <!-- pass value to displayer -->
                                    <c:set var="interMineObject" value="${object.object}" scope="request"/>
                                    <tiles:insert page="${field.displayerPage}">
                                        <tiles:put name="expr" value="${field.name}" />
                                    </tiles:insert>
                                </td>
                                <c:set var="tableCount" value="${tableCount+1}" scope="page" />
                            </c:when>
                            <c:otherwise>
                                <c:if test="${!field.doNotTruncate && !empty field.value}">
                                    <td class="label">${fieldDisplayText}&nbsp;<im:typehelp type="${field.pathString}"/></td>
                                    <td><c:out escapeXml="${field.escapeXml}" value="${field.value}" /></td>
                                    <c:set var="tableCount" value="${tableCount+1}" scope="page" />
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                        </tr>
                    </c:forEach>
                </table>
