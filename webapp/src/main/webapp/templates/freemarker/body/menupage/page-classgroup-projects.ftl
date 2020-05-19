<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#include "menupage-checkForData.ftl">

<#if !noData>
    <section id="menupage-intro" role="region">
        <h2>${page.title}</h2>
        <p>Derzeit werden mit Blick auf die landesseitigen Anforderungen zur Transparenz der Forschung die Leitlinie 1 – Transparenz der Projektförderungen umgesetzt und zunächst jährlich zum Stichtag 1.12. laufende drittmittelfinanzierte Projekte im System abgebildet (erstmalig entsprechend dieser Anforderung seit 2015). 
        Unter Beachtung etwaiger Vertraulichkeitsregelungen wird Aufschluss gegeben über die institutionelle Verortung, den Titel, die Laufzeit, die Fördersumme, die Klassifizierung der Mittelgeber sowie über die jeweils erzielten Ergebnisse dieser drittmittelfinanzierten Projekte.</p>
    </section>
    
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>