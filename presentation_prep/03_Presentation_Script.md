# Dossier: Presentation Script (SCD Lab Mid)

Language: English + Roman Urdu. Technical terms stay in English.
The same text is in each slide's **speaker notes** in `02_Dossier_SCD_Lab_Mid.pptx` (PowerPoint → View → Notes, or Presenter View).

**Timing:** The full script takes about 18–20 minutes at a calm pace. Then do the live demo (see `04_Demo_and_Video_Guide.md`).

**If Sir gives you only 8–10 minutes:** say the slides marked ⏩ in one or two sentences, or skip them. These are 11 (journey), 12 (UI/UX), 13–15 (screenshots, because the live demo shows them) and 21 (privacy). Never skip the problem, the user flows or the business model (17–20): Sir specifically asked for those.

**Delivery tips**
- Look at Sir, not the screen. Point at the diagram while explaining a flow.
- When you say "Phase 2", say it confidently. It is a planned scope decision, not an excuse.
- If Sir interrupts with a question, answer it, then say "Main next slide par continue karti hoon."

---

## Slide 1: Title: Dossier

Assalam o Alaikum Sir. Main Alina Raza hoon, registration number FA23-BSE-015. Aaj main apna Software Construction and Development ka project present karoon gi: "Dossier: Scholarship Application Planner".

Tagline hai: "Plan your scholarships. Track your applications. Never miss a deadline."

Pehle main idea, problem aur solution explain karoon gi, phir user flows, business model aur architecture, aur end mein live demo.

## Slide 2: 01 · App overview

Dossier ek mobile app hai jo students ko help karti hai ke woh apni saari scholarship applications ek jagah organise aur track kar sakein.

Student har scholarship khud add karta hai: deadline, link, notes. Phir us ki requirements list karta hai aur jaise jaise kaam hota hai, unhein tick karta hai.

Important point: Dossier scholarship search engine nahi hai. Yeh websites se data scrape nahi karti. Yeh ek personal planner hai. Is ka kaam hai scattered notes, WhatsApp messages, browser tabs aur spreadsheets ko replace karna.

Right side par app at a glance hai: Android app Flutter mein, data phone par SQLite mein offline save hota hai, reminders local notifications se aate hain, aur teen focused AI features hain.

Plans do hain: Free, aur Dossier Pro, jo Phase 2 hai. Is ki detail main business model mein bataoon gi.

## Slide 3: 02 · Problem

Ab problem dekhte hain. Students aksar ek waqt mein kai scholarships par apply karte hain, aur har scholarship ki apni deadline, apne documents aur apne steps hote hain.

Yeh information aaj kal bohat jagah bikhri hoti hai: browser tabs, phone notes, WhatsApp, Excel sheets, PDF files aur emails. Koi ek jagah nahi jahan poori picture nazar aaye.

Is ka result right side par hai: deadline bhool jana, koi document miss ho jana, recommendation letter late maangna, motivation letter late start karna. Aur agar phone lost ho jaye to saari planning bhi chali jati hai.

Ek simple tool jo sab organised rakhe, yeh stress kam kar sakta hai aur students time par complete application submit kar sakte hain.

## Slide 4: 03 · Proposed solution

Is problem ka solution Dossier hai. Main ne isay chaar pillars mein design kiya hai.

Organise: har scholarship apni country, deadline, link aur notes ke saath ek jagah.

Track: har application ki requirements ka checklist, aur progress percentage, jaise "3 of 6, 50%". Saath mein status: Not Started, In Progress, Ready to Submit, Submitted.

Remind: urgent, due soon aur overdue deadlines days-left ke saath, aur deadline se 7 din aur 2 din pehle 9 baje local reminder. Yeh offline bhi kaam karta hai.

Assist: AI pasted requirements ko checklist mein convert karta hai, batata hai pehle kis application par kaam karna hai, aur short progress summary deta hai.

Objectives simple hain: missed deadlines kam karna, progress visible karna, aur ek neat, consistent mobile experience dena.

## Slide 5: 04 · Target users

Target users woh students hain jo ek se zyada scholarships par apply karte hain aur organised rehna chahte hain. Koi technical knowledge zaroori nahi.

Chaar groups hain: Master's aur PhD applicants jinhein bohat saari deadlines aur documents track karne hote hain; final-year undergraduates jinhein clear plan aur early reminders chahiye; multi-scholarship applicants jo paanch ya zyada jagah apply karte hain; aur woh students jin ke paas counsellor nahi, jinhein simple checklist chahiye.

Last column "Likely plan" business model se connected hai: heavy users Pro ki taraf jate hain, light users Free par khush rehte hain.

Example user Alina hai, final-year student jo Erasmus Mundus, DAAD aur Stipendium Hungaricum par apply kar rahi hai. Yahi sample data demo mein bhi hai.

## Slide 6: 05 · Key features

Yeh main features hain. Upar ki row core planner hai: applications add, edit, delete; chaar statuses; requirement checklist; aur progress percentage.

Neeche ki row: Home dashboard jo active, urgent aur submitted count dikhata hai; Deadlines screen jo urgent, due soon, later aur overdue groups banati hai; offline reminders; aur AI assistant.

Har tile par plan likha hai. Free plan mein paanch active applications hain. Submitted applications count nahi hoti.

Neeche Pro ke features hain: cloud backup aur sync, document vault, PDF report aur calendar, dark mode, aur custom reminders. Yeh Phase 2 hai. App mein in par PRO label laga hai aur tap karne par Dossier Pro screen khulti hai; kabhi silently fail nahi hota.

## Slide 7: 06 · Modules (two phases)

Document mein aath modules hain. Main ne project ko do phases mein divide kiya hai, aur main honestly batana chahti hoon ke kya implement hai aur kya design stage par hai.

Phase 1, left side: Application Management, Requirement Checklist, Deadline Management, AI Assistant aur Settings. Yeh sab app mein working hain, data SQLite mein persist hota hai, aur offline chalta hai.

Phase 2, right side: Account aur Cloud Sync, Pro, Trial aur Billing, aur Document Vault aur Export. In ke screens app mein design preview ke taur par hain, aur server logic Cloud Functions mein TypeScript mein draft hai.

Phase 2 ke liye Firebase project aur Google Play Console merchant account chahiye, aur billing tab test hoti hai jab app Play Store ke test track par ho. Is liye main ne pehle woh Free plan complete kiya jo akela bhi useful hai, jaisa document kehta hai.

## Slide 8: 07 · Screens and navigation

Navigation simple rakhi hai. Bottom par chaar tabs hain: Home, Deadlines, AI Assistant aur Settings.

Pehli dafa app khulti hai to Splash, phir teen pages ka onboarding, phir Home. Onboarding sirf first launch par aata hai.

Home se plus button Add Application kholta hai. Kisi card par tap karo to Application Details, aur wahan se Requirements Checklist. Checklist se "Generate with AI" seedha AI Assistant kholta hai, aur woh application pehle se selected hoti hai.

Rule yeh hai ke koi bhi application Home se do taps mein mil jaye. Doosri screens back arrow ke saath tabs ke upar khulti hain.

## Slide 9: 08 · User flows (1/3): core planner

Ab user flows. Har box ek step hai. Black box start hai, grey box end.

Flow 1, first-time user: Splash, Onboarding, Home, Add Application, details enter, Save, aur Application Details.

Flow 2, add scholarship: Home se Add, details aur deadline, Save, phir requirements add karna, aur wapas dashboard par.

Flow 3, complete requirements: Details se Requirements, ek requirement select karke complete mark karna; progress foran update hoti hai, Home ke card par bhi.

Yeh teeno flows app mein fully working hain. Demo mein main yahi dikhaoon gi.

## Slide 10: 09 · User flows (2/3): AI and reminders

Doosre teen flows AI aur reminders ke hain.

Flow 4, AI checklist: student scholarship website se requirements text paste karta hai, Generate dabata hai, list review aur edit karta hai, application choose karta hai aur add karta hai. Jo items pehle se maujood hain woh skip ho jate hain, aur app batati hai kitne skip hue. Kuch bhi bina confirmation save nahi hota.

Flow 5, AI priority: AI Assistant mein "Analyze My Applications" ek hi click mein priority order aur summary dono deta hai. Kisi item par tap karo to woh application khul jati hai.

Flow 6, reminder: deadline save hote hi 7 din aur 2 din pehle 9 baje ke reminders schedule hote hain. Notification par tap karne se wahi application khulti hai. Agar deadline badle to purane reminders cancel ho kar naye lagte hain; Submitted ya delete karne par cancel ho jate hain.

## Slide 11: 10 · User flows (3/3): plan flows

Yeh business flows hain jo business model ko support karte hain.

Flow 10, Free limit: yeh app mein implemented hai. Free user jab chhati active application add karne ki koshish karta hai to Upgrade sheet khulti hai, jis mein teen options hain: Try Pro, Manage my applications, ya Not now.

Flow 7, free trial: Pro feature ya plan card se Dossier Pro screen, phir "Start 7-day trial", sign-in, server eligibility check karta hai, aur Pro unlock hota hai. Card nahi maanga jata.

Flow 8: trial khatam hone se 2 din aur 1 din pehle reminders, phir Trial ended screen, plan choose karna, Google Play ki payment sheet mein card, server purchase verify karta hai, phir Pro active.

Flow 9: agar student subscribe na kare to Free par wapas; agar paanch se zyada active hain to woh 5 choose karta hai, baaqi read-only lock ho jati hain, aur koi data delete nahi hota.

Flow 7, 8 aur 9 Phase 2 design hain; in ki screens app mein preview ke taur par dekhi ja sakti hain.

## ⏩ Slide 12: 11 · User journey

User journey Alina ki kahani hai, pehli dafa app kholne se le kar application submit karne tak.

Woh app kholti hai aur bina sign-in Free par hoti hai. Erasmus Mundus add karti hai aur reminders lag jate hain. Requirements paste karti hai aur AI checklist bana deta hai.

Phir DAAD add karke Pro trial try karti hai, vault mein documents rakhti hai aur custom reminders set karti hai. AI se poochti hai pehle kya karoon, to Erasmus recommend hota hai.

Trial ke reminders aate hain, trial khatam hota hai, aur woh yearly plan Google Play se leti hai.

Akhir mein CV, motivation letter aur recommendation letter complete karti hai, 100% hota hai, status Submitted karti hai aur us ke reminders band ho jate hain.

Grey steps Phase 2 ke hain. Baaqi saare steps aaj app mein chalte hain.

## ⏩ Slide 13: 12 · UI/UX design

Design theme ka naam "Calm Academic" hai. App ko Google Play ki real productivity app jaisa feel dena tha: clean, calm aur samajhne mein aasan.

Principles left par hain: Material design patterns; har screen par ek purpose aur ek main button; 48 dp touch targets; text 12 sp se chhota nahi; aur colour hamesha text label ke saath, taake colour-blind user bhi samajh sake.

Layout ek grid par hai: 4 dp base unit aur 20 dp side margin har screen par.

Colours: deep blue primary, jo trust aur education se linked hai; teal progress aur AI ke liye; gold sirf Pro ke liye; aur red, amber, green urgent, due soon aur done ke liye, kyunke log yeh colours pehle se samajhte hain.

Font Poppins hai, aur woh app ke andar bundled hai, is liye offline bhi same nazar aata hai.

## ⏩ Slide 14: 13 · Application screenshots (1/3)

Yeh actual app ke screenshots hain, latest build se.

Pehla onboarding hai. Doosra Home dashboard: greeting, aaj ki date, Free plan card, teen summary cards aur upcoming applications, har ek par days-left chip aur progress bar.

Teesra Application Details: status dropdown, progress card, requirements preview aur information, jis mein deadline, reminders aur link hain.

Chautha Requirements Checklist: progress card, "Generate with AI" button, add field, aur har item ko tick, rename ya delete karne ka option.

## ⏩ Slide 15: 14 · Application screenshots (2/3)

Yeh doosra set hai.

AI Checklist: paste kiye gaye text se generated items, jinhein student review aur edit kar sakta hai, aur target scholarship choose karke save karta hai.

Priority aur Summary: ranked order, har application ki reason ke saath, aur ek short progress summary.

Deadlines: urgent, due soon, later aur overdue groups, aur upar filter chips.

Settings: plan card, reminders, appearance, AI info, CSV export, Pro options aur clear data.

## ⏩ Slide 16: 15 · Application screenshots (3/3)

Yeh business model wali screens hain.

Add Application form validation ke saath: name 2 se 80 characters, country optional, aur link mein https khud lag jata hai. Past date par confirmation, aur duplicate name aur deadline par warning.

Upgrade sheet jo paanch active ki limit par khulti hai. Yeh working hai.

Dossier Pro screen: features, yearly aur monthly plans; yearly pehle se selected. Neeche clearly likha hai ke purchasing Phase 2 mein active hogi.

Subscription and Billing: current Free plan, trial kaise kaam karta hai, aur Pro screens ke design previews.

## Slide 17: 16 · AI features

AI sirf wahan use kiya hai jahan woh clearly help karta hai. Koi open chatbot nahi, sirf teen fixed features.

Feature 1, checklist generator: left side par document ka example hai. Input ek lamba sentence hai aur output saat clean items. "Two recommendation letters" se do alag items bante hain.

Feature 2 aur 3, priority aur summary: app sirf har active application ka naam, days left aur progress bhejti hai. Notes, links ya personal details kabhi nahi jate.

Implementation: agar Gemini API key configured ho to Gemini use hota hai. Warna, aur internet na ho tab bhi, ek offline rule-based engine chalta hai jo sentences ko split karta hai, "applicants must provide" jaise phrases hata deta hai, aur deadline aur progress se ranking karta hai. Is liye demo internet ke bina bhi chalta hai.

Production design mein, Phase 2 mein, key server par Secret Manager mein hogi aur Cloud Function monthly allowance check karega: Free 5, Pro 300.

## Slide 18: 17 · Business model: Free vs Pro

Ab business model. Pehle Free versus Pro.

Free plan forever free hai aur akela bhi useful hai: 5 active applications, saare requirements, progress aur deadlines, fixed reminders 7 aur 2 din pehle 9 baje, AI 5 uses a month, CSV export, aur koi account nahi chahiye.

Pro un students ke liye hai jo bohat zyada jagah apply karte hain ya extra safety chahte hain: unlimited applications, custom reminder days aur time, 300 AI uses, cloud backup aur sync, document vault, PDF report aur calendar, aur dark mode.

Do cheezein dono plans mein same hain: koi advertisement nahi, aur Pro khatam hone par koi data delete nahi hota.

## Slide 19: 18 · Business model canvas

Yeh business model canvas hai, taake poora model ek nazar mein samajh aaye.

Customer segments woh chaar groups hain jo main ne pehle bataye. Value proposition: har scholarship ek jagah, deadline kabhi miss na ho, offline chale, AI typing bachaye, aur koi ads na hon.

Channels: Google Play Store, aur student communities jaise university societies aur scholarship groups. Yeh proposed marketing channel hai.

Customer relationship self-service hai: reminders aur honest no-card trial.

Revenue streams sirf subscriptions hain: Rs 499 monthly ya Rs 3,999 yearly. Ads nahi, data selling nahi.

Key partners Google Play, Firebase aur Google Cloud, aur AI API provider hain. Costs: Play developer account, cloud aur AI usage, jo allowance se capped hai, aur Google Play ki subscription service fee.

## Slide 20: 19 · Revenue model

Revenue model freemium subscription hai.

Teen price points hain: Free forever; Pro monthly Rs 499; aur Pro yearly Rs 3,999, jo taqreeban Rs 333 per month banta hai, yani 33% saving. Yearly by default selected hota hai, taake retention behtar ho.

Conversion funnel left se right: student Free par bina account start karta hai. Value moment tab aata hai jab woh chhati application add karta hai ya kisi Pro feature par tap karta hai. Phir 7 din ka trial, bina card. Phir Google Play se subscription. Aur yearly plan aur reminders retention mein help karte hain.

Payments sirf Google Play Billing se hoti hain, kyunke digital subscription ke liye Play policy yahi kehti hai. Card details Google Play ki sheet mein enter hoti hain, Dossier kabhi card nahi dekhti. Google Play subscriptions par 15% service fee rakhta hai.

Future revenue ideas document se: student discount codes, aur counsellors ya parents ke liye shared applications.

## Slide 21: 20 · Trial, payment and loopholes

Trial aur billing ka main rule yeh hai ke har plan decision server par hota hai, app par nahi, taake koi loophole na rahe.

Trial rules: exactly 7 din yani 168 ghante, server time se. Card nahi chahiye. Verified account zaroori hai. Ek account ek dafa, aur ek phone ek dafa. Trial ke baad automatically koi charge nahi hota.

Purchase steps: app Google Play se real local price load karti hai, student subscribe karta hai, Play payment sheet dikhata hai, app purchase token server ko bhejti hai, aur server Google Play Developer API se verify aur acknowledge karke Pro unlock karta hai.

Right side par loopholes aur un ke rules hain: reinstall ya nayi email se naya trial nahi milta, kyunke account aur phone ka hash server par hai. Phone ka clock peeche karne se kuch nahi hota, kyunke server time decide karta hai. Local storage edit karne se Pro unlock nahi hota, kyunke entitlement server-only hai. Refund par server foran Pro hata deta hai.

Yeh Phase 2 design hai, aur is ka server code functions folder mein draft hai.

## ⏩ Slide 22: 21 · Privacy and security

Privacy aur security do levels par hai.

Aaj ki app, Phase 1: saara data sirf phone par SQLite mein. Koi account nahi, koi ads ya tracking nahi. AI ko sirf requirement text, ya naam, days left aur progress jata hai. Permissions sirf notifications, exact alarms, boot completed aur internet: contacts, location ya camera nahi. User apna data CSV mein export kar sakta hai, aur "Clear data" se DELETE type karke sab mita sakta hai.

Phase 2 design: Firebase security rules jahan har user sirf apna data padh aur likh sakta hai; entitlements aur trial claims sirf Cloud Functions likh sakte hain; App Check; secrets Secret Manager mein; app ke andar account deletion; aur payment sirf Google Play se, app mein koi card form nahi.

## Slide 23: 22 · Architecture and technology

Architecture layered hai, aur folder structure feature-based hai.

Upar Presentation layer: Flutter screens aur chaar tabs ki navigation.

Us ke neeche State layer: Provider package ke ChangeNotifier providers. ScholarshipProvider applications, counts aur Free limit sambhalta hai; RequirementProvider checklist; DeadlineProvider filters; aur AiProvider AI results.

Phir Data layer: repositories, jo SQL queries ko UI se alag rakhti hain, aur neeche sqflite ka SQLite database.

Side par services hain: NotificationService local reminders ke liye, AiService jo Gemini ya offline engine use karta hai, LocalSettingsService jo shared_preferences mein settings save karta hai, aur ExportService CSV ke liye.

Dashed box Phase 2 hai: Firebase Auth, Firestore, Cloud Functions aur Play Billing.

Provider is liye choose kiya kyunke yeh simple aur Flutter team ka recommended approach hai. SQLite is liye kyunke data relational hai: ek scholarship ki bohat saari requirements. Aur offline-first is liye kyunke reminders aur planning internet ke bina bhi chalni chahiye.

## Slide 24: 23 · Data model and testing

Data model mein do main tables hain. Scholarships table mein UUID id, name, country, deadline, link, status, notes, reminder settings aur timestamps hain.

Requirements table mein id, scholarshipId foreign key, title, isDone aur sortOrder hain. Relationship one-to-many hai, aur ON DELETE CASCADE hai, yani scholarship delete ho to us ki requirements bhi delete ho jati hain.

Progress store nahi hoti. Yeh har dafa calculate hoti hai: completed divided by total, times 100. Is se data kabhi out of sync nahi hota. Agar requirements zero hain to "No requirements yet" dikhta hai, 0% nahi.

Quality: 34 automated tests pass hote hain: date rules, validation, database CRUD aur cascade delete, AI fallback, duplicate skip aur CSV. Flutter analyze 0 issues. Aur main ne har flow manually end-to-end test kiya, app restart ke baad data persistence bhi.

## Slide 25: 24 · Future improvements

Future improvements. Sab se pehle Phase 2 integrate karna hai: Firebase sign-in aur sync, aur Google Play Billing ke saath real trial aur subscription.

Us ke baad document ke ideas: student profile ke hisaab se scholarship discovery; same codebase se iOS release; home screen widget jo agli deadline dikhaye; counsellor ya parent ke saath shared applications; motivation letter ke liye essay helper; Urdu language; aur Google Play offer codes se student discounts.

Chhote technical improvements bhi hain: requirements ko drag karke reorder karna, aur time zone change par reminders reschedule karna.

## Slide 26: Conclusion

Conclusion: Dossier ek real aur common problem solve karti hai. Students bohat saari scholarships ki deadlines, requirements aur documents ka track kho dete hain.

Phase 1 aaj complete aur working hai: offline planner, checklist, progress, deadlines, reminders, AI assistant aur Free limit, aur yeh tested hai.

Business model honest freemium hai: useful Free plan, no-card 7-day trial, Google Play se subscription, aur koi ads nahi. Har plan decision server par hoga, taake trial ya limits mein koi loophole na ho.

Ab main live demo dikhati hoon, aur demo video ka YouTube link bhi submit kiya hai. Thank you Sir. Koi question ho to zaroor poochiye.
