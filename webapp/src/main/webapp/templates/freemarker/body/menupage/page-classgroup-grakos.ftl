<#-- $This file is distributed under the terms of the license in LICENSE$ -->

<#include "menupage-checkForData.ftl">

<#if !noData>
    <section id="menupage-intro" class="uos_style" role="region">
        <h2>${page.title}</h2>
        <p>Die Graduiertenkollegs und Promotionsprogramme an der Universität Osnabrück fördern Promovierende aus dem In- und Ausland in einem interdisziplinären Forschungsumfeld. Die Promovierenden erhalten die Gelegenheit zu eigenständiger Forschung und intensivem fachlichen Austausch. Sie bieten den Doktorand:innen die Möglichkeit zur interdisziplinären Weiterbildung, Vernetzung und Zusammenarbeit. Die Teilnehmenden erhalten eine intensive fachliche Betreuung und haben die Möglichkeit, über das „Zentrum für Promovierende und Postdocs“ an zahlreichen Weiterbildungsangeboten teilzunehmen.
            <br>Datenstand: Januar 2024</p>
    </section>
    <#include "menupage-browse.ftl">
    
    ${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/menupage/menupage.css" />')}
    
    <#include "menupage-scripts.ftl">
<#else>
    ${noDataNotification}
</#if>
