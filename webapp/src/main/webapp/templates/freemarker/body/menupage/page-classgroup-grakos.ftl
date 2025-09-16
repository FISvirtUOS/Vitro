<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#include "menupage-checkForData.ftl">

<#if !noData>
    <section id="menupage-intro" class="uos_style" role="region">
        <h2>${page.title}</h2>
        <p>Die Graduiertenkollegs und Promotionsprogramme an der Universität Osnabrück fördern Promovierende aus dem In- und Ausland in einem interdisziplinären Forschungsumfeld, bieten die Gelegenheit zu eigenständiger Forschung und intensivem fachlichen Austausch. Die Promovierenden erhalten eine intensive fachliche Betreuung und haben die Möglichkeit, über das <a href="https://www.uni-osnabrueck.de/universitaet/einrichtungen-von-a-z/zentrum-fuer-promovierende-und-postdocs-zepros" title="Zentrum für Promovierende und Postdocs (Externer Link - öffnet in neuem Fenster" target="_blank">„Zentrum für Promovierende und Postdocs“</a> an zahlreichen Weiterbildungs- und Vernetzungsangeboten teilzunehmen.
            <br>Datenstand: Januar 2024</p>
    </section>
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>
