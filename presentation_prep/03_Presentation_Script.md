# Dossier: Presentation Script (16 slides)

English + Roman Urdu; technical terms in English. The same text is in each slide's speaker notes.
**Time:** about 10–12 minutes, then the live demo.

---

## Slide 1: Title

Assalam o Alaikum Sir. Main Alina Raza, FA23-BSE-015. Mera project "Dossier: Scholarship Application Planner" hai, ek Android app jo students ko apni saari scholarship applications ek jagah plan aur track karne mein help karti hai. Tagline hai: Plan your scholarships, track your applications, never miss a deadline.

## Slide 2: Project at a glance (FYP idea breakdown)

Yeh slide Sir ke FYP Idea Breakdown ke points ek nazar mein dikhati hai.

Domain mobile hai: Android app, Flutter mein. Sub-domain Generative AI aur NLP hai, kyunke LLM pasted requirements ko checklist banata hai. Industry Education hai.

Actors: student, jo Free ya Pro user hai, aur system actors: AI service, Google Play Billing aur Android ka notification scheduler. Admin nahi hai.

Goal: koi deadline ya document miss na ho. Business model freemium hai: Free plan, aur Pro Rs 499 monthly ya Rs 3,999 yearly. Koi ads nahi.

## Slide 3: The problem

Problem yeh hai ke students ek waqt mein kai scholarships par apply karte hain, aur har ek ki apni deadline aur documents hote hain.

Pehla: information bikhri hoti hai: browser tabs, notes, WhatsApp, Excel aur emails mein.

Doosra: koi ek view nahi jo bataye kya due hai aur kya missing hai.

Teesra: is ki wajah se deadlines miss hoti hain, documents reh jate hain, aur recommendation letter late maanga jata hai.

## Slide 4: Proposed solution

Solution Dossier hai. Is ke chhe main functions hain, jin mein se teen core hain.

Core: applications add karna deadline ke saath; har application ka requirements checklist aur progress percentage; aur urgency ke hisaab se deadlines, offline reminders ke saath.

Baaqi teen: AI checklist generator, AI priority aur summary, aur Free plan ki limit jo business model se judi hai.

Sab kuch phone par SQLite mein save hota hai, internet aur account ke baghair.

## Slide 5: Modules

App ke paanch working modules hain, aur har ek ki apni screens hain: Applications, Requirements, Deadlines, AI Assistant, aur Settings.

Neeche teen Phase 2 modules hain: accounts aur sync, Pro trial aur billing, aur document vault. In ki screens app mein preview ke taur par hain, aur server code draft hai.

## Slide 6: Scope

Scope mein: applications, checklist aur progress, deadlines aur reminders, teen AI features, Settings aur CSV export, aur Free plan ki limit. Phase 2 mein accounts, sync, Pro billing aur vault.

Out of scope: scholarships scrape karna ya search engine, admin panel ya web version, general AI chatbot, Google Play ke ilawa payment, aur abhi iOS. Is se project focused rehta hai: Dossier planner hai, search engine nahi.

## Slide 7: User flow 1: add an application

Pehla user flow, core flow: application add karna.

Student plus dabata hai. App pehle check karti hai: kya paanch active applications already hain? Agar haan, to Upgrade sheet khulti hai. Agar nahi, to form khulta hai.

Student name, deadline aur link dalta hai. Agar data invalid ho, jaise name ek character ka, to error dikhta hai aur woh theek karta hai.

Save par 7 din aur 2 din pehle 9 baje ke reminders lag jate hain. Phir student requirements add karta hai aur tick karta hai, aur progress Home par update hoti hai.

## Slide 8: User flow 2: AI checklist

Doosra flow AI checklist ka hai.

Student scholarship website se requirements copy karta hai, AI tab mein paste karke Generate dabata hai. Agar Gemini key aur internet ho to Gemini JSON list deta hai; warna offline rule-based engine text ko items mein todta hai.

Dono raaston se student list review aur edit karta hai, phir application choose karke save karta hai. Jo items pehle se maujood hain woh skip ho jate hain. Design decision: confirmation ke baghair kuch save nahi hota.

## Slide 9: User flows 3 and 4: reminders and Pro

Teesra aur chautha flow.

Flow 3, reminders: deadline save hone par app check karti hai ke reminders on hain aur application submitted nahi. Agar haan, to 7 aur 2 din pehle notification schedule hoti hai, aur us par tap karne se wahi application khulti hai.

Flow 4, Pro upgrade, jo Phase 2 design hai: student PRO feature ya limit se Dossier Pro screen par aata hai. Agar trial use nahi hua to server 7 din ka trial deta hai, bina card ke. Warna Google Play se subscribe karta hai, aur server purchase verify karke Pro unlock karta hai.

## Slide 10: Business model

Business model freemium hai.

Table mein Free aur Pro ka farq hai: Free mein 5 active applications, fixed reminders aur 5 AI uses a month; Pro mein unlimited applications, custom reminders, 300 AI uses, backup, vault aur dark mode.

Right side par wajah: koi ads nahi, kyunke data personal hai. Free plan akela bhi useful hai. Pro un ke liye hai jo bohat zyada jagah apply karte hain. Payment sirf Google Play Billing se, 7 din ka no-card trial, aur Google subscriptions par 15% fee rakhta hai.

## Slide 11: Tools and technology

Tools and technology. Frontend Flutter aur Dart hai, Provider state management ke saath. Backend Phase 1 mein nahi hai; saari logic phone par chalti hai. Phase 2 mein Firebase Cloud Functions.

Database SQLite hai, offline-first. Third-party API Google Gemini hai, aur Phase 2 mein Firebase aur Google Play Billing.

LLM: Gemini, prompt engineering aur JSON output ke saath. RAG, LangChain ya dataset ki zaroorat nahi, kyunke input khud student ka pasted text hai aur hum koi model train nahi karte. Testing mein 34 automated tests pass hote hain.

## Slide 12: Constraints

Major constraints jin ke hisaab se design kiya: LLM ke liye internet, is liye offline fallback banaya. Digital subscriptions ke liye Google Play Billing laazmi hai. Android 13 par notification permission chahiye. App size 25 MB se kam rakhni hai. AI ki cost ke liye monthly allowance hai. Aur privacy: data phone par rehta hai.

## Slide 13: Related systems

Related systems: spreadsheets flexible hain lekin reminders aur automatic progress nahi dete. To-do apps mein lists hain lekin scholarship ka model nahi. Scholarship portals scholarships dhoondne mein help karte hain lekin aap ki applications track nahi karte. Common App sirf apne member US colleges ke liye hai.

Gap yeh hai: kisi bhi source ki scholarship ke liye ek offline personal planner, AI checklist ke saath.

## Slide 14: The app (1)

Yeh actual app ke screenshots hain. Home dashboard plan, counts aur upcoming applications dikhata hai. Application details mein status, progress aur reminders hain. Requirements checklist mein tick karne se progress foran badalti hai. Aur Deadlines screen urgency ke groups mein hai.

## Slide 15: The app (2)

Doosre screenshots: AI checklist jo pasted text se items banata hai; Priority aur summary; Free limit par Upgrade sheet; aur Dossier Pro screen jo Phase 2 preview hai.

## Slide 16: Conclusion

Conclusion: Dossier students ka asal problem solve karti hai: deadlines aur documents ka track rakhna. Phase 1 working aur tested hai: offline planner, checklist, reminders, AI aur Free limit. Business model honest freemium hai.

Demo video ka link slide par hai. Ab main live demo dikhati hoon. Thank you Sir.
