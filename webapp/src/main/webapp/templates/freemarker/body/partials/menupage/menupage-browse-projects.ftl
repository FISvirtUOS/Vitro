<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#-- Template for browsing individuals in class groups for menupages -->

<#import "lib-string.ftl" as str>
<noscript>
<p style="padding: 20px 20px 20px 20px;background-color:#f8ffb7">${i18n().browse_page_javascript_one} <a href="${urls.base}/browse" title="${i18n().index_page}">${i18n().index_page}</a> ${i18n().browse_page_javascript_two}</p>
</noscript>

<section id="noJavascriptContainer" class="hidden">
<section id="browse-by" role="region">
    <nav role="navigation">
        

        <div class="row">
        <ul id="browse-classes">
            <#list vClassGroup?sort_by("displayRank") as vClass>
                <#------------------------------------------------------------
                Need to replace vClassCamel with full URL that allows function
                to degrade gracefully in absence of JavaScript. Something
                similar to what Brian had setup with widget-browse.ftl
                ------------------------------------------------------------->
                <#assign vClassCamel = str.camelCase(vClass.name) />
                <#-- Only display vClasses with individuals -->
                <#if (vClass.entityCount > 0)>
                    <li id="${vClassCamel}"><a href="#${vClassCamel}" title="${i18n().browse_all_in_class}" data-uri="${vClass.URI}">${vClass.name} <span id="class-counter" class="count-classes">(${vClass.entityCount})</span></a></li>
                </#if>
            </#list>
        </ul>
        </div>
        

        
        <div class="row">
            <select id="filterRT" class="uos-select-style" onchange="setFilter(this);" name="ProjektMittelgeber">
                <option selected value="">Projektstatus</option>
                <option valuve="laufend"><span>laufend</span></option>
                <option value="abgeschlossen"><span></span>abgeschlossen</option>
            </select>
            <#if projacademicDeptDG?has_content>
                <select id="filterFB" class="uos-select-style" onchange="setFilter(this);" name="Projektstatus">
                    <option selected value="">Fachbereich</option>

                    <#list projacademicDeptDG as resultRow>
                    <#assign uri = resultRow["individualUri"] />
                    <#assign label = resultRow["name"]?replace("\n", " ") />
                        <option value=${uri?url}><span>${label?html}</span></option>
                    </#list>        
                </select>
            </#if>
        </div>

        <div class="row">
        
            <div id="filter_container">
                <#if projFundDonerDG?has_content>
                    <select id="filterMG" class="uos-select-style" onchange="setFilter(this);" name="ProjektMittelgeber">
                        <option selected value="">Mittelgeber</option>

                        <#list projFundDonerDG as resultRow>
                        <#assign uri = resultRow["individualUri"] />
                        <#assign label = resultRow["name"]?replace("\n", " ") />
                            <option value=${uri?url}><span>${label?html}</span></option>
                        </#list>        
                    </select>
                </#if>
        </div></div>

        <div id="button_container">
            <button type="button" id="applyFilterButton">Filter anwenden</button>

            <button type="button" onclick="cloneSelect()">MG Filter hinzufügen</button>

            <button type="button" id="resetFilterButton" onclick="resetFilter()" style="display: none;" disabled>Reset Filter</button>
        </div>

        <#-- show "selected" filter -->
        <div id="show_filter_container">
            <p style="display: none;" class="show-filter" id="showfilterRT"></p>
            <p style="display: none;" class="show-filter" id="showfilterFB"></p>
            <p style="display: none;" class="show-filter" id="showfilterMG"></p>
        </div>

        <#-- for saving the active filters -->
        <div id="save_filter_container" style="display: none;">
            <input style="display: none;" type="text" id="savefilterRT"/>
            <input style="display: none;" type="text" id="savefilterFB"/>
            <input style="display: none;" type="text" id="savefilterMG"/>
        </div>
        

        <nav id="alpha-browse-container" role="navigation">
            <#assign alphabet = ["A", "B", "C", "D", "E", "F", "G" "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] />
            <ul id="alpha-browse-individuals">
                <li><a href="#" class="selected" data-alpha="all" title="${i18n().select_all}">${i18n().all}</a></li>
                <#list alphabet as letter>
                    <li><a href="#" data-alpha="${letter?lower_case}" title="${i18n().browse_all_starts_with(letter)}">${letter}</a></li>
                </#list>
            </ul>
        </nav>
    </nav>
    
    <section id="individuals-in-class" role="region">
        <ul role="list">

            <#-- Will be populated dynamically via AJAX request -->
        </ul>
    </section>
</section>
<div class="modal"><!-- Place at bottom of page --></div>
</section>
<script type="text/javascript">
    $('section#noJavascriptContainer').removeClass('hidden');

    var selectionCounter = 0
    function cloneSelect() {
      var select = document.getElementById("filterMG");
      var clone = select.cloneNode(true);
      var name = select.getAttribute("name") + selectionCounter;
      clone.id = select.getAttribute("id") + selectionCounter;
      clone.setAttribute("name", name);
      document.getElementById("filter_container").appendChild(clone);

    var select = document.getElementById("savefilterMG");
      var clone = select.cloneNode(true);
      clone.id = select.getAttribute("id") + selectionCounter;
      document.getElementById("save_filter_container").appendChild(clone);

      var select = document.getElementById("showfilterMG");
      var clone = select.cloneNode(true);
      clone.id = select.getAttribute("id") + selectionCounter++;
      clone.innerHTML = "";
      document.getElementById("show_filter_container").appendChild(clone);
      $("#" + clone.id).hide();
    }

    function setFilter(el) {
        console.log("wird gerade ausgeaut ;)");
    }

    function resetFilter() {
        console.log("Reset Filter...");

        $("#filterRT").val("");
        $("#savefilterRT").val("");
        $("#showfilterRT").text("");
        $("#showfilterRT").hide();

        $("#filterFB").val("");
        $("#savefilterFB").val("");
        $("#showfilterFB").text("");
        $("#showfilterFB").hide();

        $("#filterMG").val("");
        $("#savefilterMG").val("");
        $("#showfilterMG").text("");
        $("#showfilterMG").hide();

        var count = 0;
        while($("#savefilterMG" + count).length) {
            
            $("#filterMG" + count).remove();
            $("#savefilterMG" + count).remove();
            $("#showfilterMG" + count).remove();
            count = count + 1;
        }

        selectionCounter = 0;

        // ToDo reset Session vars


        $("#resetFilterButton").prop('disabled', true);
        $("#resetFilterButton").removeAttr("style").hide();
    }

    $('#browse-classes li a').on('click', function(event) {
        resetFilter();
    });
</script>