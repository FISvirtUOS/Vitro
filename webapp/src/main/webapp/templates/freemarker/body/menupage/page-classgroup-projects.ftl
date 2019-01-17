<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#include "menupage-checkForData.ftl">

<#if !noData>
    <section id="menupage-intro" role="region">
        <h2>${page.title}</h2>
        <p>Derzeit werden mit Blick auf die landesseitigen Anforderungen zur Transparenz der Forschung zunächst nur zum Stichtag 1.12.2015 laufende und bis 31.12.2017 abgeschlossene drittmittelfinanzierte Projekte im System abgebildet. Unter Beachtung etwaiger Vertraulichkeitsregelungen wird Aufschluss gegeben über die institutionelle Verortung, den Titel, die Laufzeit, die Fördersumme, die Klassifizierung der Mittelgeber sowie über die jeweils erzielten Ergebnisse dieser drittmittelfinanzierten Projekte.
Im Laufe des akademischen Jahres 2019 werden diese Informationen sukzessive über am Stichtag 1.12.2018 laufende drittmittelfinanzierte Projekte ergänzt.</p>
    </section>
    
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>