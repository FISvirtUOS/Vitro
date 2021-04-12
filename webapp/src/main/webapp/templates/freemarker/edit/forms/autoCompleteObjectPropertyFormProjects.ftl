<#-- $This file is distributed under the terms of the license in LICENSE$ -->
<#--Assign variables from editConfig-->

<#assign rangeVClassURI = "http://kerndatensatz-forschung.de/owl/Basis#Drittmittelprojekt" />
<#assign objectTypes = "http://kerndatensatz-forschung.de/owl/Basis#Drittmittelprojekt" />
<#assign objectTypesSize = objectTypes?length />
<#assign objectTypesExist = false />
<#assign multipleTypes = false />
<#if (objectTypesSize > 1)>
	<#assign objectTypesExist = true />
</#if>
<#if objectTypes?contains(",")>
	<#assign multipleTypes = true/>
</#if>
<#assign sparqlForAcFilter = "SELECT ?objectVar WHERE { ?objectVar a <http://kerndatensatz-forschung.de/owl/Basis#Drittmittelprojekt> .}" />
<#assign editMode = "add" />
<#assign propertyNameForDisplay = "Link zum Projekt" />
<#assign titleVerb = "${i18n().add_capitalized}" >
<#assign objectLabel = "" />
<#assign selectedObjectUri = ""/>
<#assign submitButtonText = "${i18n().create_entry}" />
<#assign objectExternalIDString = "object" + "${citation.externalId}" />

<#--In order to fill out the subject-->
<#assign acFilterForIndividuals =  "" />

        <input type="hidden" name="editKey" id="editKey" value="editkey_needs_to_be_set" role="input" />
        

        <#---This section should become autocomplete instead-->
        <p>
			<label for="object"> ${i18n().project_name_capitalized}:</label>
			<input class="acSelector" size="50"  type="text" id="object" name="objectLabel" acGroupName="object${citation.externalId}" value="${objectLabel}" />
		</p>

		<div class="acSelection" acGroupName="object${citation.externalId}" >
			<p class="inline">
				<label>${i18n().selected}:</label>
				<span class="acSelectionInfo"></span>
				<a href="" class="verifyMatch"  title="${i18n().verify_this_match}">(${i18n().verify_this_match}</a> ${i18n().or}
                <a href="#" class="changeSelection" id="changeSelection${citation.externalId}">${i18n().change_selection})</a>
            </p>
            <input class="acUriReceiver" type="hidden" id="objectVar${citation.externalId}" name="objectVar${citation.externalId}" value="${selectedObjectUri}" />
		</div>

        <#--The above section should be autocomplete-->

<p>&nbsp;</p>




<#assign sparqlQueryUrl = "${urls.base}/ajax/sparqlQuery" >
<#--Passing in object types only if there are any types returned, otherwise
the parameter should not be passed at all to the search.
Also multiple types parameter set to true only if more than one type returned-->
    <script type="text/javascript">
    var customFormData  = {
        acUrl: '${urls.base}/autocomplete?tokenize=true',
        <#if objectTypesExist = true>
            acTypes: {'${objectExternalIDString}': '${objectTypes}'},
        </#if>
        <#if multipleTypes = true>
            acMultipleTypes: 'true',
        </#if>
        editMode: '${editMode}',
        typeName:'${propertyNameForDisplay}',
        acSelectOnly: 'true',
        sparqlQueryUrl: '${sparqlQueryUrl}',
        sparqlForAcFilter: '${sparqlForAcFilter}',
        acFilterForIndividuals: '',
        defaultTypeName: '${propertyNameForDisplay}', // used in repair mode to generate button text
        baseHref: '${urls.base}/individual?uri='
    };
    var i18nStrings = {
        selectAnExisting: '${i18n().select_one}',
        orCreateNewOne: '${i18n().or_create_new_one}',
        selectedString: '${i18n().selected}'
    };
    </script>
<#--
	 edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.generators.AutocompleteObjectPropertyFormGenerator
	 edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.generators.AddAttendeeRoleToPersonGenerator
-->

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/js/jquery-ui/css/smoothness/jquery-ui-1.12.1.css" />')}
 ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customForm.css" />')}
 ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/templates/freemarker/edit/forms/css/customFormWithAutocomplete.css" />')}


 ${scripts.add('<script type="text/javascript" src="${urls.base}/js/jquery-ui/js/jquery-ui-1.12.1.min.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/customFormUtils.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/browserUtils.js"></script>',
              '<script type="text/javascript" src="${urls.base}/templates/freemarker/edit/forms/js/customFormWithAutocompleteForProjectsDOI.js"></script>')}
