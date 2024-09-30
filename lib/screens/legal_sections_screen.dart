import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // For text-to-speech
// Import the DataTableWidget

class LegalSectionsScreen extends StatefulWidget {
  const LegalSectionsScreen({super.key});

  @override
  _LegalSectionsScreenState createState() => _LegalSectionsScreenState();
}

class _LegalSectionsScreenState extends State<LegalSectionsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  String _searchQuery = '';

  // Static data for legal sections
  final List<Map<String, String>> legalSections = [
    {
      'Chapter & Section': '1. Short title, commencement and application.',
      'Short Description': 'This section defines the title, commencement, and application of the law.'
    },
    {
      'Chapter & Section': '2. Definitions.',
      'Short Description': 'Provides definitions for terms used in the legislation.'
    },
    {
      'Chapter & Section': '3. General Explanations and expressions.',
      'Short Description': 'Outlines general explanations and expressions related to the law.'
    },
    {
      'Chapter & Section': '4. Punishments.',
      'Short Description': 'Details the various punishments applicable under the law.'
    },
    {
      'Chapter & Section': '5. Commutation of sentence of death or imprisonment for life.',
      'Short Description': 'Describes the conditions for commuting sentences of death or life imprisonment.'
    },
    {
      'Chapter & Section': '6. Fractions of terms of punishment.',
      'Short Description': 'Explains how to deal with fractions of terms of punishment.'
    },
    {
      'Chapter & Section': '7. Sentence may be (in certain cases of imprisonment) wholly or partly rigorous or simple.',
      'Short Description': 'Discusses the nature of sentences that may be rigorous or simple.'
    },
    {
      'Chapter & Section': '8. Amount of fine, liability in default of payment of fine, etc.',
      'Short Description': 'Details fines and liabilities for non-payment.'
    },
    {
      'Chapter & Section': '9. Limit of punishment of offence made up of several offences.',
      'Short Description': 'Sets limits on punishments for offences consisting of multiple violations.'
    },
    {
      'Chapter & Section': '10. Punishment of person guilty of one of several offences, the judgment stating that it is doubtful of which.',
      'Short Description': 'Describes the punishment for individuals guilty of multiple offences.'
    },
    {
      'Chapter & Section': '11. Solitary confinement.',
      'Short Description': 'Explains the conditions and regulations regarding solitary confinement.'
    },
    {
      'Chapter & Section': '12. Limit of solitary confinement.',
      'Short Description': 'Sets the limits for the duration of solitary confinement.'
    },
    {
      'Chapter & Section': '13. Enhanced punishment for certain offences after previous conviction.',
      'Short Description': 'Discusses enhanced punishments for repeat offenders.'
    },
    {
      'Chapter & Section': '14. Act done by a person bound, or by mistake of fact believing himself bound, by law.',
      'Short Description': 'Explains actions taken by individuals under a legal obligation or mistake.'
    },
    {
      'Chapter & Section': '15. Act of Judge when acting judicially.',
      'Short Description': 'Describes the actions of a judge in their judicial capacity.'
    },
    {
      'Chapter & Section': '16. Act done pursuant to the judgment or order of Court.',
      'Short Description': 'Covers acts performed following a court judgment or order.'
    },
    {
      'Chapter & Section': '17. Act done by a person justified, or by mistake of fact believing himself justified, by law.',
      'Short Description': 'Explains justifiable acts performed under the law or by mistake.'
    },
    {
      'Chapter & Section': '18. Accident in doing a lawful act.',
      'Short Description': 'Discusses accidents occurring during the performance of lawful acts.'
    },
    {
      'Chapter & Section': '19. Act likely to cause harm, but done without criminal intent, and to prevent other harm.',
      'Short Description': 'Covers acts that may cause harm but are performed without criminal intent.'
    },
    {
      'Chapter & Section': '20. Act of a child under seven years of age.',
      'Short Description': 'Addresses the legal implications of acts committed by children under seven.'
    },
    {
      'Chapter & Section': '21. Act of a child above seven and under twelve of immature understanding.',
      'Short Description': 'Discusses the legal considerations for children between seven and twelve.'
    },
    {
      'Chapter & Section': '22. Act of a person of mental illness.',
      'Short Description': 'Explains legal considerations for individuals with mental illness.'
    },
    {
      'Chapter & Section': '23. Act of a person incapable of judgment by reason of intoxication caused against his will.',
      'Short Description': 'Covers legal aspects of actions taken under involuntary intoxication.'
    },
    {
      'Chapter & Section': '24. Offence requiring a particular intent or knowledge committed by one who is intoxicated.',
      'Short Description': 'Discusses offences that require intent or knowledge and their implications when committed under intoxication.'
    },
    {
      'Chapter & Section': '25. Act not intended and not known to be likely to cause death or grievous hurt, done by consent.',
      'Short Description': 'Explains acts performed with consent that do not intend to cause death or injury.'
    },
    {
      'Chapter & Section': '26. Act not intended to cause death, done by consent in good faith for person’s benefit.',
      'Short Description': 'Covers acts performed in good faith that do not intend to cause death.'
    },
    {
      'Chapter & Section': '27. Act done in good faith for benefit of child or person with mental illness, by or by consent of guardian.',
      'Short Description': 'Discusses acts performed for the benefit of children or those with mental illness.'
    },
    {
      'Chapter & Section': '28. Consent known to be given under fear or misconception.',
      'Short Description': 'Covers issues of consent given under duress or misunderstanding.'
    },
    {
      'Chapter & Section': '29. Exclusion of acts which are offences independently of harm caused.',
      'Short Description': 'Outlines acts that are considered offences regardless of harm.'
    },
    {
      'Chapter & Section': '30. Act done in good faith for benefit of a person without consent.',
      'Short Description': 'Discusses acts performed for someone’s benefit without their consent.'
    },
    {
      'Chapter & Section': '31. Communication made in good faith.',
      'Short Description': 'Covers legal protections for communications made in good faith.'
    },
    {
      'Chapter & Section': '32. Act to which a person compelled by threats.',
      'Short Description': 'Explains acts performed under compulsion from threats.'
    },
    {
      'Chapter & Section': '33. Act causing slight harm.',
      'Short Description': 'Addresses the legal considerations of acts causing minor harm.'
    },
    {
      'Chapter & Section': '34. Things done in private defence.',
      'Short Description': 'Discusses legal justifications for actions taken in private defense.'
    },
    {
      'Chapter & Section': '35. Right of private defence of the body and of property.',
      'Short Description': 'Explains the rights related to private defense of oneself and property.'
    },
    {
      'Chapter & Section': '36. Right of private defence against the act of a person with mental illness, etc.',
      'Short Description': 'Covers private defense rights against individuals with mental illness.'
    },
    {
      'Chapter & Section': '37. Acts against which there is no right of private defence.',
      'Short Description': 'Outlines scenarios where private defense rights do not apply.'
    },
    {
      'Chapter & Section': '38. When the right of private defence of the body extends to causing death.',
      'Short Description': 'Explains conditions under which private defense can lead to death.'
    },
    {
      'Chapter & Section': '39. When such right extends to causing any harm other than death.',
      'Short Description': 'Discusses the limits of private defense in terms of harm.'
    },
    {
      'Chapter & Section': '40. Commencement and continuance of the right of private defence of the body.',
      'Short Description': 'Outlines when the right of private defense commences and its duration.'
    },
    {
  'Chapter & Section': '41. When the right of private defence of property extends to causing death.',
  'Short Description': 'Allows use of deadly force to protect property in certain circumstances.'
},
{
  'Chapter & Section': '42. When such right extends to causing any harm other than death.',
  'Short Description': 'Permits harm to protect property without necessarily causing death.'
},
{
  'Chapter & Section': '43. Commencement and continuance of the right of private defence of property.',
  'Short Description': 'Details when the right of private defence begins and ends.'
},
{
  'Chapter & Section': '44. Right of private defence against deadly assault when there is risk of harm to innocent person.',
  'Short Description': 'Provides protection against deadly attacks posing risk to innocents.'
},
{
  'Chapter & Section': '45. Abetment of a thing.',
  'Short Description': 'Addresses the act of encouraging or aiding in the commission of an act.'
},
{
  'Chapter & Section': '46. Abettor.',
  'Short Description': 'Defines the role and responsibility of a person who abets an offence.'
},
{
  'Chapter & Section': '47. Abetment in India of offences outside India.',
  'Short Description': 'Covers abetment of crimes committed outside Indian jurisdiction.'
},
{
  'Chapter & Section': '48. Abetment outside India for offence in India.',
  'Short Description': 'Details consequences for abetting crimes in India from abroad.'
},
{
  'Chapter & Section': '49. Punishment of abetment if the act abetted is committed in consequence and where no express provision is made for its punishment.',
  'Short Description': 'Explains penalties for abetment resulting in an act when not expressly stated.'
},
{
  'Chapter & Section': '50. Punishment of abetment if person abetted does act with different intention from that of abettor.',
  'Short Description': 'Specifies penalties when abetted actions differ in intent from the abettor.'
},
{
  'Chapter & Section': '51. Liability of abettor when one act abetted and different act done.',
  'Short Description': 'Clarifies liability of abettors when the actual act differs from what was abetted.'
},
{
  'Chapter & Section': '52. Abettor when liable to cumulative punishment for act abetted and for act done.',
  'Short Description': 'States that an abettor can face punishment for both abetting and the act.'
},
{
  'Chapter & Section': '53. Liability of abettor for an effect caused by the act abetted different from that intended by the abettor.',
  'Short Description': 'Describes abettor’s liability for unintended outcomes of the abetted act.'
},
{
  'Chapter & Section': '54. Abettor present when offence is committed.',
  'Short Description': 'Discusses the implications for abettors present during the commission of an offence.'
},
{
  'Chapter & Section': '55. Abetment of offence punishable with death or imprisonment for life.',
  'Short Description': 'Covers abetment related to serious crimes punishable by severe penalties.'
},
{
  'Chapter & Section': '56. Abetment of offence punishable with imprisonment.',
  'Short Description': 'Details abetment for offences leading to imprisonment as punishment.'
},
{
  'Chapter & Section': '57. Abetting commission of offence by the public or by more than ten persons.',
  'Short Description': 'Addresses abetting actions by groups or the public committing an offence.'
},
{
  'Chapter & Section': '58. Concealing design to commit offence punishable with death or imprisonment for life.',
  'Short Description': 'Covers consequences for concealing intentions of severe crimes.'
},
{
  'Chapter & Section': '59. Public servant concealing design to commit offence which it is his duty to prevent.',
  'Short Description': 'Defines liabilities for public servants who hide intentions of crimes they should prevent.'
},
{
  'Chapter & Section': '60. Concealing design to commit offence punishable with imprisonment.',
  'Short Description': 'Details punishments for hiding intentions of crimes leading to imprisonment.'
},
{
  'Chapter & Section': '61. Criminal conspiracy.',
  'Short Description': 'Defines what constitutes a conspiracy to commit a crime.'
},
{
  'Chapter & Section': '62. Punishment for attempting to commit offences punishable with imprisonment for life or other imprisonment.',
  'Short Description': 'Outlines penalties for attempts to commit serious crimes.'
},
{
  'Chapter & Section': '63. Rape.',
  'Short Description': 'Defines the act of rape and its legal implications.'
},
{
  'Chapter & Section': '64. Punishment for rape.',
  'Short Description': 'Details penalties for those convicted of rape.'
},
{
  'Chapter & Section': '65. Punishment for rape in certain cases.',
  'Short Description': 'Specifies additional punishments for aggravated cases of rape.'
},
{
  'Chapter & Section': '66. Punishment for causing death or resulting in persistent vegetative state of victim.',
  'Short Description': 'Addresses penalties for causing death or severe harm to a victim.'
},
{
  'Chapter & Section': '67. Sexual intercourse by husband upon his wife during separation or by a person in authority.',
  'Short Description': 'Covers the legal implications of non-consensual sexual acts in specific relationships.'
},
{
  'Chapter & Section': '68. Sexual intercourse by a person in authority.',
  'Short Description': 'Details offences involving sexual acts by those in positions of authority.'
},
{
  'Chapter & Section': '69. Sexual intercourse by employing deceitful means etc.',
  'Short Description': 'Describes legal consequences for sexual acts obtained through deceit.'
},
{
  'Chapter & Section': '70. Gang rape.',
  'Short Description': 'Defines gang rape and its associated penalties.'
},
{
  'Chapter & Section': '71. Punishment for repeat offenders.',
  'Short Description': 'Covers harsher penalties for individuals with previous convictions.'
},
{
  'Chapter & Section': '72. Disclosure of identity of the victim of certain offences, etc.',
  'Short Description': 'Specifies legal repercussions for revealing identities of victims in certain cases.'
},
{
  'Chapter & Section': '73. Assault or criminal force to woman with intent to outrage her modesty.',
  'Short Description': 'Covers acts of violence or force aimed at degrading a woman’s dignity.'
},
{
  'Chapter & Section': '74. Sexual harassment and punishment for sexual harassment.',
  'Short Description': 'Defines sexual harassment and outlines related penalties.'
},
{
  'Chapter & Section': '75. Assault or use of criminal force to woman with intent to disrobe.',
  'Short Description': 'Details punishments for assaults aimed at disrobing a woman.'
},
{
  'Chapter & Section': '76. Voyeurism.',
  'Short Description': 'Defines voyeurism and the associated legal consequences.'
},
{
  'Chapter & Section': '77. Stalking.',
  'Short Description': 'Covers the legal implications and penalties for stalking behavior.'
},
{
  'Chapter & Section': '78. Word, gesture or act intended to insult the modesty of a woman.',
  'Short Description': 'Details legal repercussions for actions that demean a woman’s dignity.'
},
{
  'Chapter & Section': '79. Dowry death.',
  'Short Description': 'Covers the offence of causing death related to dowry disputes.'
},
{
  'Chapter & Section': '80. Cohabitation caused by a man deceitfully inducing a belief of lawful marriage.',
  'Short Description': 'Details penalties for deceitful cohabitation under the guise of marriage.'
},
{
  'Chapter & Section': '81. Marrying again during lifetime of husband or wife.',
  'Short Description': 'Addresses legal implications of bigamy.'
},
{
  'Chapter & Section': '82. Marriage ceremony fraudulently gone through without lawful marriage.',
  'Short Description': 'Defines penalties for fraudulent marriage ceremonies.'
},
{
  'Chapter & Section': '83. Enticing or taking away or detaining with criminal intent a married woman.',
  'Short Description': 'Covers consequences for enticing a married woman unlawfully.'
},
{
  'Chapter & Section': '84. Husband or relative of husband of a woman subjecting her to cruelty.',
  'Short Description': 'Addresses cruelty by husbands or their relatives towards women.'
},
{
  'Chapter & Section': '85. Kidnapping, abducting or inducing woman to compel her marriage, etc.',
  'Short Description': 'Defines legal implications of inducing a woman into marriage against her will.'
},
{
  'Chapter & Section': '86. Causing miscarriage.',
  'Short Description': 'Covers penalties for causing miscarriage unlawfully.'
},
{
  'Chapter & Section': '87. Causing miscarriage without woman’s consent.',
  'Short Description': 'Details consequences for causing miscarriage without consent.'
},
{
  'Chapter & Section': '88. Death caused by act done with intent to cause miscarriage.',
  'Short Description': 'Specifies penalties for causing death during unlawful miscarriage.'
},
{
  'Chapter & Section': '89. Act done with intent to prevent child being born alive or to cause it to die after birth.',
  'Short Description': 'Defines legal repercussions for acts against newborns.'
},
{
  'Chapter & Section': '90. Causing death of quick unborn child by act amounting to culpable homicide.',
  'Short Description': 'Addresses penalties for causing death to unborn children through culpable acts.'
},
{
  'Chapter & Section': '91. Exposure and abandonment of child under twelve years, by parent or person having care of it.',
  'Short Description': 'Defines consequences for abandoning or exposing children under care.'
},
{
  'Chapter & Section': '92. Concealment of birth by secret disposal of dead body.',
  'Short Description': 'Covers legal repercussions for concealing a birth by disposing of a body.'
},
{
  'Chapter & Section': '93. Hiring, employing or engaging a child to commit an offence.',
  'Short Description': 'Addresses penalties for engaging minors in criminal activities.'
},
{
  'Chapter & Section': '94. Procuration of child.',
  'Short Description': 'Defines the act of procuring children for illegal purposes.'
},
{
  'Chapter & Section': '95. Kidnapping or abducting child under ten years with intent to steal from its person.',
  'Short Description': 'Covers legal implications of kidnapping minors for theft.'
},
{
  'Chapter & Section': '96. Selling child for purposes of prostitution, etc.',
  'Short Description': 'Addresses penalties for trafficking minors for prostitution.'
},
{
  'Chapter & Section': '97. Buying child for purposes of prostitution, etc.',
  'Short Description': 'Defines consequences for purchasing minors for sexual exploitation.'
},
{
  'Chapter & Section': '98. Culpable homicide.',
  'Short Description': 'Defines culpable homicide and its legal ramifications.'
},
{
  'Chapter & Section': '99. Murder.',
  'Short Description': 'Addresses the legal definition and penalties for murder.'
},
{
  'Chapter & Section': '100. Culpable homicide by causing death of person other than person whose death was intended.',
  'Short Description': 'Describes consequences for unintended fatal outcomes of culpable homicide.'
},
{
  'Chapter & Section': '101. Punishment for murder.',
  'Short Description': 'Outlines penalties associated with murder convictions.'
},
{
  'Chapter & Section': '102. Punishment for murder by life-convict.',
  'Short Description': 'Covers additional penalties for convicted murderers already serving life sentences.'
},
{
  'Chapter & Section': '103. Punishment for culpable homicide not amounting to murder.',
  'Short Description': 'Specifies penalties for lesser forms of culpable homicide.'
},
{
  'Chapter & Section': '104. Causing death by negligence.',
  'Short Description': 'Defines legal repercussions for causing death through negligent actions.'
},
{
  'Chapter & Section': '105. Abetment of suicide of child or person with mental illness.',
  'Short Description': 'Addresses penalties for abetting suicide in vulnerable individuals.'
},
{
  'Chapter & Section': '106. Abetment of suicide.',
  'Short Description': 'Defines legal consequences for abetting suicide generally.'
},
{
  'Chapter & Section': '107. Attempt to murder.',
  'Short Description': 'Outlines penalties for attempts to commit murder.'
},
{
  'Chapter & Section': '108. Attempt to commit culpable homicide.',
  'Short Description': 'Covers penalties for attempts at culpable homicide.'
},
{
  'Chapter & Section': '109. Organised crime.',
  'Short Description': 'Defines legal ramifications and penalties for organized criminal activities.'
},
{
  'Chapter & Section': '110. Petty organised crime or organised in general.',
  'Short Description': 'Defines petty organized crimes and their implications.'
},
{
  'Chapter & Section': '111. Offence of terrorist act.',
  'Short Description': 'Covers acts classified as terrorism and their legal consequences.'
},
{
  'Chapter & Section': '112. Hurt.',
  'Short Description': 'Defines the legal concept of hurt in criminal law.'
},
{
  'Chapter & Section': '113. Voluntarily causing hurt.',
  'Short Description': 'Addresses penalties for intentionally causing hurt to another.'
},
{
  'Chapter & Section': '114. Grievous hurt.',
  'Short Description': 'Defines grievous hurt and its legal ramifications.'
},
{
  'Chapter & Section': '115. Voluntarily causing grievous hurt.',
  'Short Description': 'Covers penalties for intentionally causing grievous hurt.'
},
{
  'Chapter & Section': '116. Voluntarily causing hurt or grievous hurt by dangerous weapons or means.',
  'Short Description': 'Outlines consequences for using dangerous means to cause harm.'
},
{
  'Chapter & Section': '117. Voluntarily causing hurt or grievous hurt to extort property, or to constrain to an illegal act.',
  'Short Description': 'Addresses penalties for causing harm to extort property or force illegal acts.'
},
{
  'Chapter & Section': '118. Voluntarily causing hurt or grievous hurt to extort confession, or to compel restoration of property.',
  'Short Description': 'Covers penalties for causing harm to extract confessions or restore property.'
},
{
  'Chapter & Section': '119. Voluntarily causing hurt or grievous hurt to deter public servant from his duty.',
  'Short Description': 'Details penalties for harming public servants to obstruct their duties.'
},
{
  'Chapter & Section': '120. Voluntarily causing hurt or grievous hurt on provocation.',
  'Short Description': 'Specifies legal consequences for harm caused in response to provocation.'
},
{
  'Chapter & Section': '121. Causing hurt by means of poison, etc., with intent to commit an offence.',
  'Short Description': 'Defines penalties for causing harm through poison with criminal intent.'
},
{
  'Chapter & Section': '122. Voluntarily causing grievous hurt by use of acid, etc.',
  'Short Description': 'Covers severe penalties for causing grievous hurt using corrosive substances.'
},
{
  'Chapter & Section': '123. Act endangering life or personal safety of others.',
  'Short Description': 'Addresses acts that threaten the life or safety of individuals.'
},
{
  'Chapter & Section': '124. Wrongful restraint.',
  'Short Description': 'Defines wrongful restraint and its legal consequences.'
},
{
  'Chapter & Section': '125. Wrongful confinement.',
  'Short Description': 'Covers penalties for the wrongful confinement of individuals.'
},
{
  'Chapter & Section': '126. Force.',
  'Short Description': 'Defines the legal meaning of force in the context of criminal law.'
},
{
  'Chapter & Section': '127. Criminal force.',
  'Short Description': 'Addresses the use of force in a criminal context and its consequences.'
},
{
  'Chapter & Section': '128. Assault.',
  'Short Description': 'Defines assault and the legal ramifications of such actions.'
},
{
  'Chapter & Section': '129. Punishment for assault or criminal force otherwise than on grave provocation.',
  'Short Description': 'Outlines penalties for assault not provoked by grave circumstances.'
},
{
  'Chapter & Section': '130. Assault or criminal force to deter public servant from discharge of his duty.',
  'Short Description': 'Covers penalties for obstructing public servants in their duties through force.'
},
{
  'Chapter & Section': '131. Assault or criminal force with intent to dishonor person, otherwise than on grave provocation.',
  'Short Description': 'Details legal consequences for assault aimed at dishonoring individuals.'
},
{
  'Chapter & Section': '132. Assault or criminal force in attempt to commit theft of property carried by a person.',
  'Short Description': 'Defines penalties for assault during theft attempts involving physical property.'
},
{
  'Chapter & Section': '133. Assault or criminal force in attempt wrongfully to confine a person.',
  'Short Description': 'Covers legal implications for using force to wrongfully confine individuals.'
},
{
  'Chapter & Section': '134. Assault or criminal force on grave provocation.',
  'Short Description': 'Specifies legal repercussions for assault committed under grave provocation.'
},
{
  'Chapter & Section': '135. Kidnapping.',
  'Short Description': 'Defines kidnapping and the associated legal penalties.'
},
{
  'Chapter & Section': '136. Abduction.',
  'Short Description': 'Covers the legal definition of abduction and its consequences.'
},
{
  'Chapter & Section': '137. Kidnapping or maiming a child for purposes of begging.',
  'Short Description': 'Addresses severe penalties for kidnapping or harming children for begging.'
},
{
  'Chapter & Section': '138. Kidnapping or abducting in order to murder or for ransom, etc.',
  'Short Description': 'Defines legal consequences for kidnapping with intent to murder or extort.'
},
{
  'Chapter & Section': '139. Importation of girl or boy from foreign country.',
  'Short Description': 'Covers the illegal importation of minors and associated penalties.'
},
{
  'Chapter & Section': '140. Wrongfully concealing or keeping in confinement, kidnapped or abducted person.',
  'Short Description': 'Defines penalties for concealing or confining kidnapped individuals unlawfully.'
},
{
  'Chapter & Section': '141. Trafficking of person.',
  'Short Description': 'Addresses the illegal trafficking of individuals and its severe penalties.'
},
{
  'Chapter & Section': '142. Exploitation of a trafficked person.',
  'Short Description': 'Covers legal consequences for exploiting individuals who have been trafficked.'
},
{
  'Chapter & Section': '143. Habitual dealing in slaves.',
  'Short Description': 'Defines penalties for the ongoing illegal trade of slaves.'
},
{
  'Chapter & Section': '144. Unlawful compulsory labour.',
  'Short Description': 'Addresses the illegal enforcement of compulsory labor practices.'
},
{
  'Chapter & Section': '145. Waging, or attempting to wage war, or abetting waging of war, against the Government of India.',
  'Short Description': 'Covers severe penalties for acts of war against the Government of India.'
},
{
  'Chapter & Section': '146. Conspiracy to commit offences punishable by section 145.',
  'Short Description': 'Addresses legal ramifications for conspiring to wage war against India.'
},
{
  'Chapter & Section': '147. Collecting arms, etc., with intention of waging war against the Government of India.',
  'Short Description': 'Defines penalties for collecting arms to wage war against India.'
},
{
  'Chapter & Section': '148. Concealing with intent to facilitate design to wage war.',
  'Short Description': 'Covers consequences for concealing actions to support war against India.'
},
{
  'Chapter & Section': '149. Assaulting President, Governor, etc., with intent to compel or restrain the exercise of any lawful power.',
  'Short Description': 'Addresses severe penalties for assaulting high officials to manipulate their authority.'
},
{
  'Chapter & Section': '150. Acts endangering sovereignty, unity and integrity of India.',
  'Short Description': 'Defines acts that threaten the sovereignty and integrity of the nation.'
},
{
  'Chapter & Section': '151. Waging war against Government of any foreign State at peace with the Government of India.',
  'Short Description': 'Covers penalties for waging war against peaceful foreign states.'
},
{
  'Chapter & Section': '152. Committing depredation on territories of foreign State at peace with the Government of India.',
  'Short Description': 'Addresses penalties for damaging peaceful foreign territories.'
},
{
  'Chapter & Section': '153. Receiving property taken by war or depredation mentioned in sections 153 and 154.',
  'Short Description': 'Defines penalties for receiving stolen property from war or depredation.'
},
{
  'Chapter & Section': '154. Public servant voluntarily allowing prisoner of state or war to escape.',
  'Short Description': 'Covers legal consequences for public servants enabling prisoners to escape.'
},
{
  'Chapter & Section': '155. Public servant negligently suffering such prisoner to escape.',
  'Short Description': 'Addresses negligence by public servants leading to prisoner escape.'
},
{
  'Chapter & Section': '156. Aiding escape of, rescuing or harbouring such prisoner.',
  'Short Description': 'Defines penalties for aiding in the escape of prisoners.'
},
{
  'Chapter & Section': '157. Abetting mutiny, or attempting to seduce a soldier, sailor or airman from his duty.',
  'Short Description': 'Covers legal repercussions for abetting mutiny or seducing military personnel.'
},
{
  'Chapter & Section': '158. Abetment of mutiny, if mutiny is committed in consequence thereof.',
  'Short Description': 'Details penalties for abetting mutiny when it occurs as a result.'
},
{
  'Chapter & Section': '159. Abetment of assault by soldier, sailor or airman on his superior officer, when in execution of his office.',
  'Short Description': 'Defines penalties for abetting assaults on superior officers in military service.'
},
{
  'Chapter & Section': '160. Abetment of such assault, if the assault committed.',
  'Short Description': 'Addresses penalties for abetting assault if the assault takes place.'
},
{
  'Chapter & Section': '161. Abetment of desertion of soldier, sailor or airman.',
  'Short Description': 'Covers penalties for encouraging desertion from military service.'
},
{
  'Chapter & Section': '162. Harbouring deserter.',
  'Short Description': 'Defines legal consequences for harboring military deserters.'
},
{
  'Chapter & Section': '163. Deserter concealed on board merchant vessel through negligence of master.',
  'Short Description': 'Addresses penalties for negligence leading to the concealment of deserters.'
},
{
  'Chapter & Section': '164. Abetment of act of insubordination by soldier, sailor or airman.',
  'Short Description': 'Defines penalties for abetting insubordination in military personnel.'
},
{
  'Chapter & Section': '165. Persons subject to certain Acts.',
  'Short Description': 'Specifies individuals subject to particular legal acts and obligations.'
},
{
  'Chapter & Section': '166. Wearing garb or carrying token used by soldier, sailor or airman.',
  'Short Description': 'Addresses penalties for unauthorized use of military uniforms or insignia.'
},
{
  'Chapter & Section': '167. Candidate, electoral right defined.',
  'Short Description': 'Defines electoral rights of candidates in elections.'
},
{
  'Chapter & Section': '168. Bribery.',
  'Short Description': 'Covers legal implications and penalties for bribery.'
},
{
  'Chapter & Section': '169. Undue influence at elections.',
  'Short Description': 'Addresses legal repercussions for exerting undue influence in elections.'
},
{
  'Chapter & Section': '170. Personation at elections.',
  'Short Description': 'Defines penalties for impersonating another during elections.'
},
{
  'Chapter & Section': '171. Punishment for bribery.',
  'Short Description': 'Specifies legal penalties for individuals convicted of bribery.'
},
{
  'Chapter & Section': '172. Punishment for undue influence or personation at an election.',
  'Short Description': 'Covers penalties for undue influence or impersonation during elections.'
},
{
  'Chapter & Section': '173. False statement in connection with an election.',
  'Short Description': 'Addresses penalties for making false statements related to elections.'
},
{
  'Chapter & Section': '174. Illegal payments in connection with an election.',
  'Short Description': 'Defines consequences for making illegal payments during elections.'
},
{
  'Chapter & Section': '175. Failure to keep election accounts.',
  'Short Description': 'Covers legal penalties for failing to maintain accurate election accounts.'
},
{
  'Chapter & Section': '176. Counterfeiting coin, government stamps, currency-notes or bank-notes.',
  'Short Description': 'Addresses penalties for counterfeiting monetary instruments.'
},
{
  'Chapter & Section': '177. Using as genuine, forged or counterfeit coin, Government stamp, currency-notes or bank notes.',
  'Short Description': 'Defines penalties for using counterfeit currency as genuine.'
},
{
  'Chapter & Section': '178. Possession of forged or counterfeit coin, Government stamp, currency-notes or bank-notes.',
  'Short Description': 'Covers legal consequences for possessing counterfeit monetary instruments.'
},
{
  'Chapter & Section': '179. Making or possessing instruments or materials for forging or counterfeiting coin, Government stamp, currency notes or bank-notes.',
  'Short Description': 'Defines penalties for creating tools for counterfeiting currency.'
},
{
  'Chapter & Section': '180. Making or using documents resembling currency-notes or bank-notes.',
  'Short Description': 'Addresses legal consequences for making or using false currency documents.'
},
{
  'Chapter & Section': '181. Effacing writing from substance bearing Government stamp, or removing from document a stamp used for it, with intent to cause loss to Government.',
  'Short Description': 'Defines penalties for tampering with government stamps to cause loss.'
},
{
  'Chapter & Section': '182. Using Government stamp known to have been before used.',
  'Short Description': 'Covers penalties for reusing government stamps improperly.'
},
{
  'Chapter & Section': '183. Erasure of mark denoting that stamp has been used.',
  'Short Description': 'Addresses penalties for erasing marks indicating stamp usage.'
},
{
  'Chapter & Section': '184. Prohibition of fictitious stamps.',
  'Short Description': 'Defines penalties for creating or using fictitious stamps.'
},
{
  'Chapter & Section': '185. Person employed in mint causing coin to be of different weight or composition from that fixed by law.',
  'Short Description': 'Covers penalties for tampering with coin specifications at the mint.'
},
{
  'Chapter & Section': '186. Unlawfully taking coining instrument from mint.',
  'Short Description': 'Defines penalties for unlawfully removing coining instruments from the mint.'
},
{
  'Chapter & Section': '187. Unlawful assembly.',
  'Short Description': 'Addresses legal consequences for participating in unlawful assemblies.'
},
{
  'Chapter & Section': '188. Every member of unlawful assembly guilty of offence committed in prosecution of common object.',
  'Short Description': 'Covers penalties for members of unlawful assemblies involved in offenses.'
},
{
  'Chapter & Section': '189. Rioting.',
  'Short Description': 'Defines rioting and its legal ramifications.'
},
{
  'Chapter & Section': '190. Wantonly giving provocation with intent to cause riot- if rioting be committed; if not committed.',
  'Short Description': 'Addresses penalties for provoking riots.'
},
{
  'Chapter & Section': '191. Liability of owner, occupier etc., of land on which an unlawful assembly or riot takes place.',
  'Short Description': 'Specifies liabilities for property owners during unlawful assemblies or riots.'
},
{
  'Chapter & Section': '192. Affray.',
  'Short Description': 'Defines affray and the legal consequences thereof.'
},
{
  'Chapter & Section': '193. Assaulting or obstructing public servant when suppressing riot, etc.',
  'Short Description': 'Covers penalties for obstructing public servants during riot control.'
},
{
  'Chapter & Section': '194. Promoting enmity between different groups on ground of religion, race, place of birth, residence, language, etc., and doing acts prejudicial to maintenance of harmony.',
  'Short Description': 'Addresses penalties for promoting enmity between groups based on identity.'
},
{
  'Chapter & Section': '195. Imputations, assertions prejudicial to national integration.',
  'Short Description': 'Defines legal consequences for making statements harmful to national unity.'
},
{
  'Chapter & Section': '196. Public servant disobeying law, with intent to cause injury to any person.',
  'Short Description': 'Covers penalties for public servants disobeying laws to cause harm.'
},
{
  'Chapter & Section': '197. Public servant disobeying direction under law.',
  'Short Description': 'Addresses penalties for public servants failing to follow lawful directives.'
},
{
  'Chapter & Section': '198. Punishment for non-treatment of victim.',
  'Short Description': 'Defines penalties for failing to provide treatment to victims.'
},
{
  'Chapter & Section': '199. Public servant framing an incorrect document with intent to cause injury.',
  'Short Description': 'Covers consequences for public servants creating false documents to harm others.'
},
{
  'Chapter & Section': '200. Public servant unlawfully engaging in trade.',
  'Short Description': 'Defines penalties for public servants illegally participating in trade.'
},

  {
    "Chapter & Section": "201. Public servant unlawfully buying or bidding for property.",
    "Short Description": "Defines penalties for public servants unlawfully buying or bidding on property."
  },
  {
    "Chapter & Section": "202. Personating a public servant.",
    "Short Description": "Covers legal consequences for impersonating a public servant."
  },
  {
    "Chapter & Section": "203. Wearing garb or carrying token used by public servant with fraudulent intent.",
    "Short Description": "Addresses penalties for fraudulently wearing or using symbols of public servants."
  },
  {
    "Chapter & Section": "204. Absconding to avoid service of summons or other proceeding.",
    "Short Description": "Defines penalties for evading legal processes by absconding."
  },
  {
    "Chapter & Section": "205. Preventing service of summons or other proceeding, or preventing publication thereof.",
    "Short Description": "Covers consequences for obstructing the service of legal summons or related publications."
  },
  {
    "Chapter & Section": "206. Non-attendance in obedience to an order from public servant.",
    "Short Description": "Addresses penalties for failing to attend as ordered by a public servant."
  },
  {
    "Chapter & Section": "207. Non-appearance in response to a proclamation under section 82 of Act __ of 2023.",
    "Short Description": "Defines penalties for not appearing in response to specific legal proclamations."
  },
  {
    "Chapter & Section": "208. Omission to produce document to public servant by person legally bound to produce it.",
    "Short Description": "Covers penalties for failing to produce required documents to a public servant."
  },
  {
    "Chapter & Section": "209. Omission to give notice or information to public servant by person legally bound to give it.",
    "Short Description": "Addresses consequences for not providing required information to a public servant."
  },
  {
    "Chapter & Section": "210. Furnishing false information.",
    "Short Description": "Defines penalties for providing false information to authorities."
  },
  {
    "Chapter & Section": "211. Refusing oath or affirmation when duly required by public servant to make it.",
    "Short Description": "Covers penalties for refusing to take an oath or affirmation when required."
  },
  {
    "Chapter & Section": "212. Refusing to answer public servant authorised to question.",
    "Short Description": "Addresses penalties for refusing to answer questions from authorized public servants."
  },
  {
    "Chapter & Section": "213. Refusing to sign statement.",
    "Short Description": "Defines penalties for refusing to sign a statement as required by law."
  },
  {
    "Chapter & Section": "214. False statement on oath or affirmation to public servant or person authorised to administer an oath or affirmation.",
    "Short Description": "Covers penalties for making false statements under oath to authorized officials."
  },
  {
    "Chapter & Section": "215. False information, with intent to cause public servant to use his lawful power to the injury of another person.",
    "Short Description": "Defines penalties for providing false information aimed at harming another."
  },
  {
    "Chapter & Section": "216. Resistance to the taking of property by the lawful authority of a public servant.",
    "Short Description": "Addresses penalties for resisting lawful property seizure by public servants."
  },
  {
    "Chapter & Section": "217. Obstructing sale of property offered for sale by authority of public servant.",
    "Short Description": "Covers legal consequences for obstructing the sale of property by authorized officials."
  },
  {
    "Chapter & Section": "218. Illegal purchase or bid for property offered for sale by authority of public servant.",
    "Short Description": "Defines penalties for making illegal purchases or bids on property sold by public servants."
  },
  {
    "Chapter & Section": "219. Obstructing public servant in discharge of public functions.",
    "Short Description": "Addresses penalties for obstructing public servants in the execution of their duties."
  },
  {
    "Chapter & Section": "220. Omission to assist public servant when bound by law to give assistance.",
    "Short Description": "Covers penalties for failing to assist public servants when legally obligated."
  },
  {
    "Chapter & Section": "221. Disobedience to order duly promulgated by public servant.",
    "Short Description": "Defines penalties for disobeying lawful orders issued by public servants."
  },
  {
    "Chapter & Section": "222. Threat of injury to public servant.",
    "Short Description": "Addresses penalties for threatening harm to public servants."
  },
  {
    "Chapter & Section": "223. Threat of injury to induce person to refrain from applying for protection to public servant.",
    "Short Description": "Covers consequences for threatening harm to prevent individuals from seeking help from public servants."
  },
  {
    "Chapter & Section": "224. Attempt to commit suicide to compel or restraint exercise of lawful power.",
    "Short Description": "Defines legal repercussions for attempting suicide to influence lawful authority."
  },
  {
    "Chapter & Section": "225. Giving false evidence.",
    "Short Description": "Addresses penalties for providing false evidence in legal proceedings."
  },
  {
    "Chapter & Section": "226. Fabricating false evidence.",
    "Short Description": "Covers consequences for creating false evidence in legal matters."
  },
  {
    "Chapter & Section": "227. Punishment for false evidence.",
    "Short Description": "Defines penalties for individuals convicted of providing false evidence."
  },
  {
    "Chapter & Section": "228. Giving or fabricating false evidence with intent to procure conviction of capital offence.",
    "Short Description": "Addresses severe penalties for providing false evidence to secure a capital conviction."
  },
  {
    "Chapter & Section": "229. Giving or fabricating false evidence with intent to procure conviction of offence punishable with imprisonment for life or imprisonment.",
    "Short Description": "Covers legal repercussions for providing false evidence for serious offenses."
  },
  {
    "Chapter & Section": "230. Threatening any person to give false evidence.",
    "Short Description": "Defines penalties for threatening individuals to compel them to give false evidence."
  },
  {
    "Chapter & Section": "231. Using evidence known to be false.",
    "Short Description": "Addresses consequences for knowingly using false evidence in court."
  },
  {
    "Chapter & Section": "232. Issuing or signing false certificate.",
    "Short Description": "Covers penalties for issuing or signing certificates that are known to be false."
  },
  {
    "Chapter & Section": "233. Using as true a certificate known to be false.",
    "Short Description": "Defines penalties for using a false certificate as genuine."
  },
  {
    "Chapter & Section": "234. False statement made in declaration which is by law receivable as evidence.",
    "Short Description": "Addresses penalties for making false statements in legally recognized declarations."
  },
  {
    "Chapter & Section": "235. Using as true such declaration knowing it to be false.",
    "Short Description": "Covers legal consequences for using a false declaration as true."
  },
  {
    "Chapter & Section": "236. Causing disappearance of evidence of offence, or giving false information to screen offender.",
    "Short Description": "Defines penalties for hiding evidence or providing false information to protect an offender."
  },
  {
    "Chapter & Section": "237. Intentional omission to give information of offence by person bound to inform.",
    "Short Description": "Addresses penalties for intentionally failing to report an offense when legally obligated."
  },
  {
    "Chapter & Section": "238. Giving false information respecting an offence committed.",
    "Short Description": "Covers legal repercussions for providing false information about a committed offense."
  },
  {
    "Chapter & Section": "239. Destruction of document to prevent its production as evidence.",
    "Short Description": "Defines penalties for destroying documents to prevent them from being used as evidence."
  },
  {
    "Chapter & Section": "240. False personation for purpose of act or proceeding in suit or prosecution.",
    "Short Description": "Addresses penalties for impersonating someone for legal proceedings."
  },
  {
    "Chapter & Section": "241. Fraudulent removal or concealment of property to prevent its seizure as forfeited or in execution.",
    "Short Description": "Covers penalties for unlawfully hiding property to prevent its seizure."
  },
  {
    "Chapter & Section": "242. Fraudulent claim to property to prevent its seizure as forfeited or in execution.",
    "Short Description": "Defines penalties for falsely claiming property to avoid seizure."
  },
  {
    "Chapter & Section": "243. Fraudulently suffering decree for sum not due.",
    "Short Description": "Addresses penalties for allowing fraudulent decrees for amounts not owed."
  },
  {
    "Chapter & Section": "244. Dishonestly making false claim in Court.",
    "Short Description": "Covers penalties for dishonestly claiming amounts in court."
  },
  {
    "Chapter & Section": "245. Fraudulently obtaining decree for sum not due.",
    "Short Description": "Defines penalties for fraudulently securing decrees for non-existent debts."
  },
  {
    "Chapter & Section": "246. False charge of offence made with intent to injure.",
    "Short Description": "Addresses penalties for making false accusations to harm another."
  },
  {
    "Chapter & Section": "247. Harbouring offender.",
    "Short Description": "Covers legal consequences for harboring individuals who have committed offenses."
  },
  {
    "Chapter & Section": "248. Taking gift, etc., to screen an offender from punishment.",
    "Short Description": "Defines penalties for accepting gifts to protect offenders from punishment."
  },
  {
    "Chapter & Section": "249. Offering gift or restoration of property in consideration of screening offender.",
    "Short Description": "Addresses penalties for offering gifts in exchange for screening offenders."
  },
  {
    "Chapter & Section": "250. Taking gift to help to recover stolen property, etc.",
    "Short Description": "Covers penalties for accepting gifts to facilitate the recovery of stolen property."
  },
  {
    "Chapter & Section": "251. Harbouring offender who has escaped from custody or whose apprehension has been ordered.",
    "Short Description": "Defines penalties for harboring fugitives from law enforcement."
  },
  {
    "Chapter & Section": "252. Penalty for harbouring robbers or dacoits.",
    "Short Description": "Addresses severe penalties for harboring robbers or dacoits."
  },
  {
    "Chapter & Section": "253. Public servant disobeying direction of law with intent to save person from punishment or property from forfeiture.",
    "Short Description": "Covers consequences for public servants who disobey legal directions to protect individuals from punishment."
  },
  {
    "Chapter & Section": "254. Public servant framing incorrect record or writing with intent to save person from punishment or property from forfeiture.",
    "Short Description": "Defines penalties for public servants creating false records to shield individuals from punishment."
  },
  {
    "Chapter & Section": "255. Public servant in judicial proceeding corruptly making report, etc., contrary to law.",
    "Short Description": "Addresses penalties for public servants corruptly reporting in judicial proceedings."
  },
  {
    "Chapter & Section": "256. Commitment for trial or confinement by person having authority who knows that he is acting contrary to law.",
    "Short Description": "Covers legal repercussions for authorities committing individuals contrary to the law."
  },
  {
    "Chapter & Section": "257. Intentional omission to apprehend on the part of public servant bound to apprehend.",
    "Short Description": "Defines penalties for public servants who intentionally fail to apprehend individuals."
  },
  {
    "Chapter & Section": "258. Intentional omission to apprehend on the part of public servant bound to apprehend person under sentence or lawfully committed.",
    "Short Description": "Addresses penalties for public servants failing to apprehend those under lawful commitment."
  },
  {
    "Chapter & Section": "259. Escape from confinement or custody negligently suffered by public servant.",
    "Short Description": "Covers legal consequences for negligent escape from confinement allowed by public servants."
  },
  {
    "Chapter & Section": "260. Resistance or obstruction by a person to his lawful apprehension.",
    "Short Description": "Defines penalties for resisting or obstructing lawful apprehension."
  },
  {
    "Chapter & Section": "261. Resistance or obstruction to lawful apprehension of another person.",
    "Short Description": "Addresses penalties for resisting the lawful apprehension of others."
  },
  {
    "Chapter & Section": "262. Omission to apprehend, or sufferance of escape, on part of public servant, in cases not otherwise, provided for.",
    "Short Description": "Covers consequences for public servants who fail to apprehend or allow escape in unspecified cases."
  },
  {
    "Chapter & Section": "263. Resistance or obstruction to lawful apprehension or escape or rescue in cases not otherwise provided for.",
    "Short Description": "Defines penalties for resisting lawful apprehension or escape in unspecified situations."
  },
  {
    "Chapter & Section": "264. Violation of condition of remission of punishment.",
    "Short Description": "Addresses penalties for violating conditions of punishment remission."
  },
  {
    "Chapter & Section": "265. Intentional insult or interruption to public servant sitting in judicial proceeding.",
    "Short Description": "Covers penalties for insulting or interrupting public servants during judicial proceedings."
  },
  {
    "Chapter & Section": "266. Personation of an assessor.",
    "Short Description": "Defines penalties for impersonating an assessor in legal contexts."
  },
  {
    "Chapter & Section": "267. Failure by person released on bail or bond to appear in court.",
    "Short Description": "Addresses penalties for failing to appear in court after being released on bail."
  },
  {
    "Chapter & Section": "268. Public nuisance.",
    "Short Description": "Covers legal consequences for engaging in public nuisance."
  },
  {
    "Chapter & Section": "269. Negligent act likely to spread infection of disease dangerous to life.",
    "Short Description": "Defines penalties for negligent acts that may spread life-threatening diseases."
  },
  {
    "Chapter & Section": "270. Malignant act likely to spread infection of disease dangerous to life.",
    "Short Description": "Addresses penalties for malicious acts that may spread serious infections."
  },
  {
    "Chapter & Section": "271. Disobedience to quarantine rule.",
    "Short Description": "Covers penalties for violating quarantine regulations."
  },
  {
    "Chapter & Section": "272. Adulteration of food or drink intended for sale.",
    "Short Description": "Defines penalties for adulterating food or drink intended for sale."
  },
  {
    "Chapter & Section": "273. Sale of noxious food or drink.",
    "Short Description": "Addresses penalties for selling harmful food or drink."
  },
  {
    "Chapter & Section": "274. Adulteration of drugs.",
    "Short Description": "Covers penalties for adulterating pharmaceuticals."
  },
  {
    "Chapter & Section": "275. Sale of adulterated drugs.",
    "Short Description": "Defines penalties for selling adulterated medications."
  },
  {
    "Chapter & Section": "276. Sale of drug as a different drug or preparation.",
    "Short Description": "Addresses penalties for misrepresenting drugs in sales."
  },
  {
    "Chapter & Section": "277. Fouling water of public spring or reservoir.",
    "Short Description": "Covers penalties for contaminating public water sources."
  },
  {
    "Chapter & Section": "278. Making atmosphere noxious to health.",
    "Short Description": "Defines penalties for creating unhealthy environmental conditions."
  },
  {
    "Chapter & Section": "279. Rash driving or riding on a public way.",
    "Short Description": "Addresses penalties for reckless driving or riding on public roads."
  },
  {
    "Chapter & Section": "280. Rash navigation of vessel.",
    "Short Description": "Covers penalties for reckless navigation of vessels."
  },
  {
    "Chapter & Section": "281. Exhibition of false light, mark or buoy.",
    "Short Description": "Defines penalties for displaying false navigational signals."
  },
  {
    "Chapter & Section": "282. Conveying person by water for hire in unsafe or overloaded vessel.",
    "Short Description": "Addresses penalties for transporting individuals in unsafe or overloaded vessels."
  },
  {
    "Chapter & Section": "283. Danger or obstruction in public way or line of navigation.",
    "Short Description": "Covers legal consequences for creating dangers or obstructions in public navigation."
  },
  {
    "Chapter & Section": "284. Negligent conduct with respect to poisonous substance.",
    "Short Description": "Defines penalties for negligent handling of poisonous substances."
  },
  {
    "Chapter & Section": "285. Negligent conduct with respect to fire or combustible matter.",
    "Short Description": "Addresses penalties for negligent behavior related to fire hazards."
  },
  {
    "Chapter & Section": "286. Negligent conduct with respect to explosive substance.",
    "Short Description": "Covers penalties for negligent handling of explosives."
  },
  {
    "Chapter & Section": "287. Negligent conduct with respect to machinery.",
    "Short Description": "Defines penalties for negligent operation of machinery."
  },
  {
    "Chapter & Section": "288. Negligent conduct with respect to pulling down, repairing or constructing buildings etc.",
    "Short Description": "Addresses penalties for negligent construction practices."
  },
  {
    "Chapter & Section": "289. Negligent conduct with respect to animal.",
    "Short Description": "Covers penalties for negligent behavior towards animals."
  },
  {
    "Chapter & Section": "290. Punishment for public nuisance in cases not otherwise provided for.",
    "Short Description": "Defines penalties for public nuisance where specific provisions do not exist."
  },
  {
    "Chapter & Section": "291. Continuance of nuisance after injunction to discontinue.",
    "Short Description": "Addresses penalties for persisting in a nuisance after being ordered to cease."
  },
  {
    "Chapter & Section": "292. Sale, etc., of obscene books, etc.",
    "Short Description": "Covers penalties for the sale of obscene materials."
  },
  {
    "Chapter & Section": "293. Sale, etc., of obscene objects to child.",
    "Short Description": "Defines penalties for selling obscene items to minors."
  },
  {
    "Chapter & Section": "294. Obscene acts and songs.",
    "Short Description": "Addresses penalties for performing obscene acts or songs."
  },
  {
    "Chapter & Section": "295. Keeping lottery office.",
    "Short Description": "Covers penalties for operating illegal lottery offices."
  },
  {
    "Chapter & Section": "296. Injuring or defiling place of worship, with intent to insult the religion of any class.",
    "Short Description": "Defines penalties for desecrating places of worship with intent to insult religious beliefs."
  },
  {
    "Chapter & Section": "297. Deliberate and malicious acts, intended to outrage religious feelings of any class by insulting its religion or religious beliefs.",
    "Short Description": "Addresses penalties for acts intended to incite religious outrage."
  },
  {
    "Chapter & Section": "298. Disturbing religious assembly.",
    "Short Description": "Covers penalties for disrupting religious gatherings."
  },
  {
    "Chapter & Section": "299. Trespassing on burial places, etc.",
    "Short Description": "Defines penalties for trespassing on burial grounds."
  },
  {
    "Chapter & Section": "300. Uttering words, etc., with deliberate intent to wound religious feelings.",
    "Short Description": "Defines penalties for uttering words or acts intended to hurt religious sentiments."
  },
  {
    "Chapter & Section": "301. Theft.",
    "Short Description": "Covers penalties for the act of stealing another's property."
  },
  {
    "Chapter & Section": "302. Snatching.",
    "Short Description": "Addresses penalties for snatching property from another person."
  },
  {
    "Chapter & Section": "303. Theft in a dwelling house, or means of transportation or place of worship, etc.",
    "Short Description": "Defines penalties for theft occurring in private homes, transport means, or places of worship."
  },
  {
    "Chapter & Section": "304. Theft by clerk or servant of property in possession of master.",
    "Short Description": "Covers penalties for theft committed by employees against their employer."
  },
  {
    "Chapter & Section": "305. Theft after preparation made for causing death, hurt or restraint in order to the committing of theft.",
    "Short Description": "Defines penalties for theft committed with the intent to cause serious harm."
  },
  {
    "Chapter & Section": "306. Extortion.",
    "Short Description": "Addresses penalties for obtaining property through coercion or threats."
  },
  {
    "Chapter & Section": "307. Robbery.",
    "Short Description": "Defines penalties for robbery, which involves theft with violence or threat."
  },
  {
    "Chapter & Section": "308. Dacoity.",
    "Short Description": "Covers penalties for robbery committed by a group of individuals."
  },
  {
    "Chapter & Section": "309. Robbery, or dacoity, with attempt to cause death or grievous hurt.",
    "Short Description": "Defines severe penalties for robbery or dacoity intending to cause death or serious injury."
  },
  {
    "Chapter & Section": "310. Attempt to commit robbery or dacoity when armed with deadly weapon.",
    "Short Description": "Addresses penalties for attempting robbery or dacoity while armed."
  },
  {
    "Chapter & Section": "311. Punishment for belonging to gang of robbers, dacoits, etc.",
    "Short Description": "Defines penalties for being part of a gang involved in robbery or dacoity."
  },
  {
    "Chapter & Section": "312. Dishonest misappropriation of property.",
    "Short Description": "Covers penalties for dishonestly misappropriating someone else's property."
  },
  {
    "Chapter & Section": "313. Dishonest misappropriation of property possessed by deceased person at the time of his death.",
    "Short Description": "Addresses penalties for misappropriating property of a deceased individual."
  },
  {
    "Chapter & Section": "314. Criminal breach of trust.",
    "Short Description": "Defines penalties for violating trust, typically in fiduciary relationships."
  },
  {
    "Chapter & Section": "315. Stolen property.",
    "Short Description": "Covers legal consequences for possessing stolen property."
  },
  {
    "Chapter & Section": "316. Cheating.",
    "Short Description": "Defines penalties for deceiving someone for gain."
  },
  {
    "Chapter & Section": "317. Cheating by personation.",
    "Short Description": "Addresses penalties for cheating by impersonating another person."
  },
  {
    "Chapter & Section": "318. Dishonest or fraudulent removal or concealment of property to prevent distribution among creditors.",
    "Short Description": "Covers penalties for concealing property to avoid debt obligations."
  },
  {
    "Chapter & Section": "319. Dishonestly or fraudulently preventing debt being available for creditors.",
    "Short Description": "Defines penalties for preventing creditors from collecting debts owed to them."
  },
  {
    "Chapter & Section": "320. Dishonest or fraudulent execution of deed of transfer containing false statement of consideration.",
    "Short Description": "Addresses penalties for fraudulent execution of transfer deeds with false statements."
  },
  {
    "Chapter & Section": "321. Dishonest or fraudulent removal or concealment of property.",
    "Short Description": "Defines penalties for removing or hiding property dishonestly."
  },
  {
    "Chapter & Section": "322. Mischief.",
    "Short Description": "Covers penalties for causing damage to property or harm."
  },
  {
    "Chapter & Section": "323. Mischief by killing or maiming animal.",
    "Short Description": "Addresses penalties for causing harm or death to animals."
  },
  {
    "Chapter & Section": "324. Mischief by injury, inundation, fire or explosive substance, etc.",
    "Short Description": "Defines penalties for causing mischief through various harmful means."
  },
  {
    "Chapter & Section": "325. Mischief with intent to destroy or make unsafe a rail, aircraft, decked vessel or one of twenty tons burden.",
    "Short Description": "Covers penalties for intentionally endangering transportation vehicles."
  },
  {
    "Chapter & Section": "326. Punishment for intentionally running vessel aground or ashore with intent to commit theft, etc.",
    "Short Description": "Addresses penalties for running a vessel aground to commit theft."
  },
  {
    "Chapter & Section": "327. Criminal trespass and house-trespass.",
    "Short Description": "Defines penalties for unauthorized entry onto property."
  },
  {
    "Chapter & Section": "328. House-trespass and house-breaking.",
    "Short Description": "Covers penalties for breaking into homes unlawfully."
  },
  {
    "Chapter & Section": "329. Punishment for house-trespass or house breaking.",
    "Short Description": "Addresses penalties specifically for house-trespass and breaking."
  },
  {
    "Chapter & Section": "330. House-trespass in order to commit offence.",
    "Short Description": "Defines penalties for entering a property intending to commit an offense."
  },
  {
    "Chapter & Section": "331. House-trespass after preparation for hurt, assault or wrongful restraint.",
    "Short Description": "Covers penalties for entering a property after preparing to cause harm."
  },
  {
    "Chapter & Section": "332. Dishonestly breaking open receptacle containing property.",
    "Short Description": "Defines penalties for unlawfully opening containers holding property."
  },
  {
    "Chapter & Section": "333. Making a false document.",
    "Short Description": "Addresses penalties for creating fraudulent documents."
  },
  {
    "Chapter & Section": "334. Forgery.",
    "Short Description": "Covers penalties for forging documents or signatures."
  },
  {
    "Chapter & Section": "335. Forgery of record of Court or of public register, etc.",
    "Short Description": "Defines penalties for forging court records or public registers."
  },
  {
    "Chapter & Section": "336. Forgery of valuable security, will, etc.",
    "Short Description": "Addresses penalties for forging valuable documents like securities or wills."
  },
  {
    "Chapter & Section": "337. Having possession of document described in section 335 or 336, knowing it to be forged and intending to use it as genuine.",
    "Short Description": "Defines penalties for possessing forged documents with intent to use them."
  },
  {
    "Chapter & Section": "338. Forged document or electronic record and using it as genuine.",
    "Short Description": "Covers penalties for using forged documents as if they are authentic."
  },
  {
    "Chapter & Section": "339. Making or possessing counterfeit seal, etc., with intent to commit forgery punishable under section 336.",
    "Short Description": "Defines penalties for creating or possessing counterfeit seals for forgery."
  },
  {
    "Chapter & Section": "340. Counterfeiting device or mark used for authenticating documents described in section 336, or possessing counterfeit marked material.",
    "Short Description": "Addresses penalties for counterfeiting authentication devices."
  },
  {
    "Chapter & Section": "341. Fraudulent cancellation, destruction, etc., of will, authority to adopt, or valuable security.",
    "Short Description": "Covers penalties for fraudulently cancelling or destroying important documents."
  },
  {
    "Chapter & Section": "342. Falsification of accounts.",
    "Short Description": "Defines penalties for altering accounts with dishonest intent."
  },
  {
    "Chapter & Section": "343. Property mark.",
    "Short Description": "Addresses penalties related to property marks."
  },
  {
    "Chapter & Section": "344. Tampering with property mark with intent to cause injury.",
    "Short Description": "Defines penalties for tampering with property marks to cause harm."
  },
  {
    "Chapter & Section": "345. Counterfeiting a property mark.",
    "Short Description": "Covers penalties for counterfeiting property identification marks."
  },
  {
    "Chapter & Section": "346. Making or possession of any instrument for counterfeiting a property mark.",
    "Short Description": "Addresses penalties for creating or possessing tools for counterfeiting property marks."
  },
  {
    "Chapter & Section": "347. Selling goods marked with a counterfeit property mark.",
    "Short Description": "Defines penalties for selling items marked with counterfeit property marks."
  },
  {
    "Chapter & Section": "348. Making a false mark upon any receptacle containing goods.",
    "Short Description": "Covers penalties for marking goods containers falsely."
  },
  {
    "Chapter & Section": "349. Criminal intimidation.",
    "Short Description": "Defines penalties for intimidating others through threats."
  },
  {
    "Chapter & Section": "350. Intentional insult with intent to provoke breach of peace.",
    "Short Description": "Addresses penalties for insulting others to incite disorder."
  },
  {
    "Chapter & Section": "351. Statements conducing to public mischief.",
    "Short Description": "Covers penalties for making statements that can lead to public disruption."
  },
  {
    "Chapter & Section": "352. Act caused by inducing person to believe that he will be rendered an object of the Divine displeasure.",
    "Short Description": "Defines penalties for inducing belief in divine punishment as a form of coercion."
  },
  {
    "Chapter & Section": "353. Misconduct in public by a drunken person.",
    "Short Description": "Addresses penalties for public misconduct due to intoxication."
  },
  {
    "Chapter & Section": "354. Defamation.",
    "Short Description": "Defines penalties for making false statements damaging to another's reputation."
  },
  {
    "Chapter & Section": "355. Breach of contract to attend on and supply wants of helpless person.",
    "Short Description": "Covers penalties for failing to fulfill obligations to support vulnerable individuals."
  },
  {
  "Chapter & Section": "356. Repeal and savings.",
  "Short Description": "This section explains that while certain laws are being repealed, any rights or responsibilities that existed under those laws will still remain in effect."
}

  ];

  void _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }
@override
Widget build(BuildContext context) {
  // Filter legal sections based on search query
  final filteredSections = legalSections.where((section) {
    final sectionTitle = section['Chapter & Section']!.toLowerCase();
    final description = section['Short Description']!.toLowerCase();
    return sectionTitle.contains(_searchQuery.toLowerCase()) ||
        description.contains(_searchQuery.toLowerCase());
  }).toList();

  return Scaffold(
    appBar: AppBar(
      title: const Text('Legal Sections'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200], // Light gray background
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Colors.blue, // Border color
                  width: 1.5,
                ),
              ),
              hintText: 'Search by Section number or Description...',
              hintStyle: const TextStyle(color: Color.fromARGB(255, 94, 92, 92)), // Gray hint text
              suffixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 36, 36, 36)), // Blue icon
            ),
          ),
        ),
      ),
    ),
    body: ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredSections.length,
      itemBuilder: (context, index) {
        final section = filteredSections[index];
        return GestureDetector(
          onTap: () => _speak(section['Short Description']!),
          child: Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['Chapter & Section']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,

                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    section['Short Description']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

}