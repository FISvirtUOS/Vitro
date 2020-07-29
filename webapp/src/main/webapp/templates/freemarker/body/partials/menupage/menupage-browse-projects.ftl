<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#-- Template for browsing individuals in class groups for menupages -->
<head>
	<link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.4/css/select2.min.css" rel="stylesheet" />

	<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.4/js/select2.min.js"></script>
</head>


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
            <select id="filterRT" class="uos-select-style" onchange="setFilter(this);" name="Projektstatus">
                <option selected value="">Projektstatus</option>
                <option valuve="laufend"><span>laufend</span></option>
                <option value="abgeschlossen"><span></span>abgeschlossen</option>
            </select>
            <#if projacademicDeptDG?has_content>
                <select id="filterFB" class="uos-select-style" onchange="setFilter(this);" name="Filter Fachbereich">
                    <option selected value="">Fachbereich</option>

                    <#list projacademicDeptDG as resultRow>
                    <#assign uri = resultRow["individualUri"] />
                    <#assign label = resultRow["name"]?replace("\n", " ") />
                        <option value=${uri?url}><span>${label?html}</span></option>
                    </#list>        
                </select>
            </#if>
        
            
            <#if projacademicFieldsDG?has_content>
                <select id="filterFD" class="uos-select-style" onchange="setFilter(this);" name="Filter Fach">
                    <option selected value="">Fach</option>

                    <#list projacademicFieldsDG as resultRow>
                    <#assign uri = resultRow["individualUri"] />
                    <#assign label = resultRow["name"]?replace("\n", " ") />
                        <option value=${uri?url}><span>${label?html}</span></option>
                    </#list>        
                </select>
            </#if>
            
            <#if projFundDonerDG?has_content>
                <select id="filterMG" class="uos-select-style js-select2" multiple="" onchange="setMGFilter(this);" name="ProjektMittelgeber">
                    
                    <#list projFundDonerDG as resultRow>
                    <#assign uri = resultRow["individualUri"] />
                    <#assign label = resultRow["name"]?replace("\n", " ") />
                        <option value=${uri?url}><span>${label?html}</span></option>
                    </#list>        
                </select>
            </#if>
        
        </div>

        <div class="row filter_button" id="button_container">
            <button type="button" id="applyFilterButton">Filter anwenden</button>

            <button type="button" id="resetFilterButton" onclick="resetFilter()" style="display: none;" disabled>Reset Filter</button>
        </div>

        <#-- for saving the active filters -->
        <div id="save_filter_container" style="display: none;">
            <input style="display: none;" type="text" id="savefilterRT"/>
            <input style="display: none;" type="text" id="savefilterFB"/>
            <input style="display: none;" type="text" id="savefilterFD"/>
            <input style="display: none;" type="text" id="savefilterMG"/>
        </div>
        

        <nav id="alpha-browse-container" role="navigation">
            <#assign alphabet = ["A", "B", "C", "D", "E", "F", "G" "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"] />
            <ul id="alpha-browse-individuals">
                <li><a href="#" class="selected" data-alpha="all" title="${i18n().select_all}">${i18n().all}</a></li>
                <li><a href="#" data-alpha="special" title="Sonderzeichen">#</a></li>
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

    function setFilter(el) {
        console.log("wird gerade ausgeaut ;)");
    }

    function setMGFilter(el) {
        var brands = $('#filterMG option:selected');
        var selected = [];
        $(brands).each(function(index, brand){
            selected.push([$(this).val()]);
        });

        console.log(selected);
    }

    function resetFilter() {
        console.log("Reset Filter...");

        // reset filters
        $("#filterRT").val("");
        $("#savefilterRT").val("");

        $("#filterFB").val("");
        $("#savefilterFB").val("");

        $("#filterFD").val("");
        $("#savefilterFD").val("");

        $("#filterMG").val(null).trigger('change');

        $("#resetFilterButton").prop('disabled', true);
        $("#resetFilterButton").removeAttr("style").hide();
    }

    $('#browse-classes li a').on('click', function(event) {
        resetFilter();
    });
</script>