namespace :generate_legal_and_confidentiality do
  desc "destroy all existing pages in db"
  task destroy: :environment do
    Page.destroy_all
  end

  desc "Generates the legal and confidentiality page"
  task generate: :environment do
    Page.create(
      title: "Mentions légales",
      slug: "mentions-legales",
      body: "
        <p>\r\n Responsable du site : Time for the Planet<span class='brand'>®</span>, Société en commandite par
        actions au capital de 123 456€,\r\n dont le siège social est situé 10 rue Bellecordière, 69002
        LYON\r\n </p>\r\n<p>\r\n Immatriculé au registre du commerce de Lyon sous le n° 849 876 339
        \r\n </p>\r\n<p>\r\n Numéro de TVA intracommunautaire : FR34849876339\r\n </p>\r\n<p>\r\n Contact :
        nicolas@time-planet.com\r\n </p>\r\n<p>\r\n Directeur de la publication : Nicolas Sabatier\r\n </p>\r\n<p>\r\n
        Site édité et réalisé par Time for the Planet<span class='brand'>®</span>\r\n </p>\r\n<p>\r\n Hébergé par
        Heroku, Inc. 650 7th Street San Francisco, CA 94103, USA.\r\n </p>
      "
    )

    Page.create(
      title: "Politique de protection des données personnelles",
      slug: "protection-donnees-personnelles",
      body: "
        \r\n<p>Time for the Planet<span class='brand'>®</span> est soucieux de la protection des données personnelles.
        </p>\r\n<p>Nous mettons
        en œuvre une démarche d'amélioration continue de sa conformité au Règlement général de protection des données
        (RGPD), à la Directive ePrivacy, ainsi qu'à la loi n° 78-17 du 6 janvier 1978 dite Informatique et Libertés
        pour assurer le meilleur niveau de protection à vos données personnelles.</p>\r\n<p>Pour toute information sur
        la protection des données personnelles, vous pouvez également consulter le site de la Commission Nationale de
        l'Informatique et des Libertés www.cnil.fr.</p>\r\n<h2>Qui est le responsable du traitement de mes données
        personnelles ?</h2>\r\n<p>Le responsable de traitement est la société qui définit pour quel usage et comment
        vos données personnelles sont utilisées.</p>\r\n<p>Les données personnelles collectées sur le site,
        sont traitées par :</p>\r\n<p>TIME FOR THE PLANET - RCS 849 876 339</p>\r\n<p>Domiciliée : 10, rue
        Bellecordière 69002 LYON</p>\r\n<p>Ci-après dénommée « TIME FOR THE PLANET »</p>\r\n<h2>Pourquoi
        TIME FOR THE PLANET collecte mes données personnelles ?</h2>\r\n<h3>La connaissance de nos actionnaires :
        </h3>\r\n<p>Les informations recueillies sur le formulaire sont enregistrées dans un fichier informatisé par
        TIME FOR THE PLANET, agissant en qualité de responsable de traitement, pour que vous deveniez actionnaire de
        Time for the Planet. Le remplissage de chaque ligne de ce formulaire est obligatoire afin de compléter votre
        bulletin de souscription. A défaut, nous ne pourrons pas procéder à votre enregistrement en tant qu’actionnaire.
        La base juridique du traitement est l’exécution de nos obligations légales en matière de souscription d’action
        en numéraire. Toutes les données collectées ci-dessus seront conservées jusqu’à la date effective de la cession
        ou du rachat de vos actions. Il se peut que nous partagions vos données avec nos commissaires aux comptes et
        nos avocats. Nous ne les communiquerons à personne d’autre. Vous disposez d'un droit d'accès, de rectification,
        de restriction, d’opposition et d'effacement de vos données personnelles ainsi que d'un droit de portabilité
        des données, que vous pouvez exercer à tout moment en envoyant un email à l’adresse suivante :
        laurent@time-planet.com . Si après nous avoir contacté vous estimez que vos droits ne sont pas respectés,
        vous avez également le droit de déposer une plainte auprès de la Commission nationale de l'informatique et des
        libertés (CNIL). Consultez le site cnil.fr pour plus d’informations sur vos droits</p>\r\n<h3>La sécurité de
        notre site</h3>\r\n<p>Nous collectons certaines données de navigation pour nous permettre d'assurer la
        sécurité de nos services et de détecter, d'éviter ou de retracer toute tentative de malveillance ou
        d'intrusion informatique ou toute violation des conditions d'utilisation de nos Services.<br><br></p>\r\n
        <h3>Les statistiques et performances de notre site :</h3>\r\n<p>Nous pouvons utiliser des données à des fins
        de statistiques pour analyser l'activité de notre site. Nous analysons des parcours, effectuons des mesures
        d'audience, nous mesurons par exemple le nombre de pages vues, le nombre de visites du site, ainsi que
        l'activité des visiteurs sur le site et leur fréquence de retour.</p>\r\n<h2>Quelles sont les données
        personnelles qui sont collectées me concernant ?</h2>\r\n<p>Quelles données ?</p>\r\n<p>Nous collectons et
        traitons notamment vos nom, prénom, adresse, adresse email, numéro de téléphone, données de connexions et
        données de navigation. </p>\r\n<p>Le caractère obligatoire des données vous est signalé lors de la collecte
        par un astérisque. </p>\r\n<p>Certaines données sont collectées automatiquement du fait de vos actions sur
        le site.</p>\r\n<p>Quand ?</p>\r\n<p>Nous collectons les informations que vous nous fournissez notamment
        quand :</p>\r\n<ul><li>vous devenez actionnaire de TIME FOR THE PLANET</li><li>vous naviguez sur nos sites
        </li><li>vous participez à un jeu ou un concours</li><li>vous nous contactez via la rubrique
        Contact</li></ul>\r\n<p><br></p>\r\n<p>Quelles sont les communications que je suis susceptible de recevoir ?
        </p>\r\n<p>Emails </p>\r\n<p>Suite à l’achat d’action vous recevrez un email afin de vous permettre d’avoir
        la confirmation l'exécution de la procédure. Ces messages sont nécessaires à la bonne exécution des procédures.
        La base légale de ce traitement est l’exécution de nos obligations légales en matière de souscription d’action
        en numéraire </p>\r\n<p>Newsletters</p>\r\n<p>Suite à la souscription d’action de la Société, si vous ne vous
        y êtes pas opposés, vous pouvez recevoir des informations par email. Ces newsletters vous permettent de vous
        tenir informés de l'actualité TIME FOR THE PLANET. La base légale de ce traitement est l'intérêt légitime de
        TIME FOR THE PLANET. Nous mesurons le taux d'ouverture de nos envois électroniques afin d’adapter nos outils
        d’envoi. </p>\r\n<p></p>\r\n<p>Contact téléphonique</p>\r\n<p>Si vous ne vous y êtes pas opposé vous pourrez
        être contactés par téléphone pour vous demander des précisions ou informations complémentaires. La base légale
        de ce traitement est l'intérêt légitime de TIME FOR THE PLANET.</p>\r\n<p>Sur quelle base légale et pour
        quelles durées mes données personnelles sont-elles traitées ?</p>\r\n<p>Le traitement de vos données
        personnelles est justifié par différents fondements (base légale) en fonction de l'usage que nous faisons
        des données personnelles. Vous trouverez ci-dessous les bases légales et durées de conservation que nous
        appliquons à nos principaux traitements.</p>\r\n<p>Bases légales des traitements</p>\r\n<p>Parmi les bases
        légales applicables :</p>\r\n<p>La souscription d’actions : le traitement des données personnelles est
        nécessaire à la souscription d’action à laquelle vous avez consenti.</p>\r\n<p>L'intérêt légitime :
        TIME FOR THE PLANET a un intérêt légitime à traiter vos données qui est justifié, équilibré et ne vient pas
        porter atteinte à votre vie privée. Sauf exception, vous pouvez à tout moment vous opposer à un traitement
        basé sur l'intérêt légitime en le signalant à TIME FOR THE PLANET.</p>\r\n<p>La loi : le traitement de vos
        données personnelles est rendu obligatoire par un texte de loi.</p>\r\n<p>Durées de conservation</p>\r\n<p>
        Les données sont conservées tant que vous êtes actionnaire de la Société. Si vous n’êtes pas actionnaire les
        données sont conservées pendant une durée de 3 ans à compter de votre dernière activité. Vos données sont
        ensuite archivées avec un accès restreint pour une durée supplémentaire de 36 mois pour des raisons limitées
        et autorisées par la loi ( litiges, ...). Passé ce délai, elles sont supprimées.</p>\r\n<p><br><br></p>\r\n<p>
        Comment exprimer mes choix sur l'usage de mes données ?</p>\r\n<p>Vous pouvez à tout moment retirer votre
        consentement lorsque le traitement est effectué sur cette base ou formuler une opposition concernant les
        usages de vos données décrits ci-avant : </p>\r\n<p>Par email à laurent@time-planet.com</p>\r\n<p>Par
        courrier à l'adresse : TIME FOR THE PLANET - 10 rue Bellecordière 69002 LYON</p>\r\n<p>Il convient de nous
        indiquer vos nom, prénom, e-mail et en mentionnant le motif de votre demande.</p>\r\n<p>Quels sont mes droits
        au regard de l'utilisation des données personnelles ?</p>\r\n<p>Conformément à la règlementation sur la
        protection des données personnelles, vous pouvez exercer vos droits (accès, rectification, suppression,
        opposition, limitation et portabilité le cas échéant) et définir le sort de vos données personnelles
        « post mortem » TIME FOR THE PLANET par email : laurent@time-planet.com ou par courrier :
        TIME FOR THE PLANET 10 rue Bellecordière 69002 LYON.</p>\r\n<p></p>\r\n<p>Afin de nous permettre de répondre
        rapidement, nous vous remercions de nous indiquer vos nom, prénom, e-mail et préciser l'adresse
        (email ou postale) à laquelle doit vous parvenir la réponse.</p>\r\n<p>Nous pourrons procéder à des
        vérifications d'identité afin de garantir la confidentialité et la sécurité de vos données. Dans certains
        cas une copie d'un titre d'identité portant votre signature pourra vous être demandée. Une réponse vous sera
        alors adressée dans un délai d'1 mois suivant la réception de la demande.</p>\r\n<p></p>\r\n<p>Vous disposez
        par ailleurs, du droit d'introduire une réclamation auprès de la Commission Nationale de l'Informatique et
        des Libertés (CNIL), notamment sur son site internet www.cnil.fr.</p>
      "
    )
  end
end
