// English Feng Shui Texts
class FengShuiEn {
  static const eActivators = {
    'Ağaç': [
      'Add green leafy live plants', 'Use wood textured decorative objects', 'Place tall and vertical accessories',
      'Keep natural bamboo sticks', 'Choose light green or mint details', 'Hang wooden framed nature views',
      'Use wicker or natural woven baskets', 'Bring fresh and lively flowers to the space', 'Place ivy type growing plants',
      'Add tree branch shaped artistic objects', 'Prefer cotton and linen natural fabrics', 'Add natural wooden wind chimes or furniture'
    ],
    'Ateş': [
      'Add red, orange or burgundy toned objects', 'Use lampshades giving warm yellow light', 'Place triangular or pyramid shaped accessories',
      'Keep live burning candles or candlesticks', 'Hang bright crystals drawing sunlight', 'Use warm toned incenses or aromatherapy oils',
      'Choose brightly textured and eye-catching fabrics', 'Add star shaped decors reflecting fire element', 'Hang sun or fire themed artworks',
      'Reflect the energy of pets or vitality', 'Place soft pillows with red details', 'Use a salt lamp creating a warm ambiance'
    ],
    'Toprak': [
      'Add earth, beige or tile toned items', 'Use square or horizontal rectangular furniture', 'Keep natural stones and crystals',
      'Place ceramic, clay or pottery pots', 'Choose soft, plush and low-to-ground textures', 'Use yellow, brown and tan colored pillows',
      'Hang desert or mountain view paintings', 'Add heavy and solid desktop objects', 'Set up a natural sand or stone garden (zen garden)',
      'Lay square patterned rugs balancing the center', 'Put natural salt crystals giving a grounding feeling', 'Add stone sculptures symbolizing unshakability'
    ],
    'Metal': [
      'Add white, gray or metallic bright colors', 'Use circular, oval or spherical objects', 'Place silver, gold or copper reflecting accessories',
      'Hang metal framed mirrors', 'Choose smooth and hard surfaced decorative items', 'Keep metallic sounding wind chimes or clocks',
      'Put white colored and simple flowers (e.g. white orchid)', 'Prefer minimalist and modern lined objects', 'Use shiny steel or chrome tableware',
      'Hang sky or space themed round paintings', 'Create smooth surfaces without unnecessary details', 'Add silver toned spheres increasing focus'
    ],
    'Su': [
      'Add navy blue, black or dark blue tones', 'Use wavy, curved or asymmetrical forms', 'Place glass objects and transparent accessories',
      'Keep a small table fountain or water waterfall', 'Hang dark colored mirrors symbolizing depth', 'Add water landscape, ocean or waterfall paintings',
      'Put glass vases with fresh water', 'Use sea shells or underwater themed decors', 'Choose silk or satin fabrics reflecting free flow',
      'Grow plants growing in water in dark colored pots', 'Add fluid formed and reflective surfaced trinkets', 'Hang crystal prisms refracting light like water'
    ],
  };

  static const gActivators = {
    'Para': [
      'revitalize abundance energy in the southeast corner.', 'attract prosperity by keeping the top left corner of your desk spacious.', 'make room for financial opportunities by keeping the entrance bright.',
      'add a touch that adds value to your wealth corner.', 'honor money by keeping the area you put your wallet clean and organized.', 'activate the savings energy in the prosperity center of your home.',
      'invite abundance by always keeping around the kitchen stove sparkling clean.', 'keep objects symbolizing steady growth in your money corner.', 'add value by putting an elegant box in the area you keep your financial documents.',
      'hang a paper with abundance affirmations in a visible place.', 'use details reflecting prosperity around the dining table.', 'place a decoration giving an abundance feeling opposite your entrance door.'
    ],
    'Aşk': [
      'take steps strengthening bilateral relations in the southwest corner.', 'establish romantic balance by creating symmetry in your bedroom.', 'invite harmony to your life by pairing single items.',
      'revitalize the feeling of warmth and intimacy in the relationship corner.', 'create a loving atmosphere in the center of the home.', 'make space for your partner by leaving equal space on both sides of your bed.',
      'place objects attracting love and passion in visible areas.', 'clear the energy of past relationships and make room for new love.', 'add pleasant scents and textures symbolizing romance.',
      'set up a U-shape layout encouraging communication in your living room.', 'hang artworks or photos symbolizing couples in your love corner.', 'create self-care corners that will increase your self-love.'
    ],
    'Kariyer': [
      'mobilize work and career opportunities in the north corner.', 'adjust your desk so you always face the door.', 'keep details symbolizing leadership and success on your desk.',
      'keep your vision clear to remove obstacles in your business life.', 'hang the words of mentors who inspire you in your career journey.', 'completely empty the center of your desk to increase focus.',
      'keep objects symbolizing your success goals in your field of vision.', 'strengthen your communication corner (northwest) to expand your professional network.', 'increase the feeling of support by having a solid wall behind your desk.',
      'illuminate the uncertainties in your career by increasing the lighting on your desk.', 'display your certificates of achievement to increase your reputation (south) at work.', 'use organizing office accessories that make focusing easier.'
    ],
    'Huzur': [
      'find inner peace by balancing the Tai Chi area, the center of the home.', 'reduce any visual clutter that tires the mind in the resting area.', 'simplify around the entrance door to leave stress outside.',
      'keep only objects that make you feel good in your meditation or resting corner.', 'create a wide empty space in the exact center of the house where energy can flow freely.', 'make your bedroom as minimalist as possible to increase your sleep quality.',
      'rest your soul by using natural light at the maximum level in your room.', 'create a comfortable reading corner for moments you are alone with yourself.', 'remove electronic devices from your bedroom for a digital detox.',
      'calm the vibration of the space by playing soft and serene music.', 'highlight pastel or neutral tones supporting inner silence.', 'let fresh and peaceful energy in by ventilating your home every morning.'
    ],
    'Sağlık': [
      'encourage physical and mental vitality in the east corner of the home.', 'keep corridors open to accelerate the flow of life energy (Chi).', 'protect your body\'s nutrition source by keeping your kitchen clean and organized.',
      'keep details representing vitality and renewal in your health corner.', 'support cell renewal by creating a relaxing atmosphere in your bedroom.', 'secure overall health by clearing the energy in the center of the home.',
      'prevent energy leaks by always keeping the bathroom door closed.', 'prepare a motivating corner reflecting your healthy living goals.', 'throw out stagnant energy by increasing air flow in your rooms.',
      'integrate natural healing elements into various places of the space.', 'provide a natural environment by removing harmful chemicals from your living space.', 'allow sunlight and fresh air to circulate freely in your home.'
    ],
  };

  static const eRemoves = {
    'Ağaç': [
      'immediately throw away dried, faded or dead plants', 'recycle unused, old paper and magazine piles', 'thin out heavy wooden furniture taking up unnecessary space',
      'remove rotted or damp wooden objects from the space', 'throw away broken baskets and worn wicker items', 'move excessively large potted plants suffocating the space',
      'clean out expired files and old letters', 'remove tree-shaped obstacles blocking passage ways', 'throw dry flower arrangements and lifeless leaves in the trash',
      'empty old wooden boxes that have lost their function', 'prune ivy that has lost its vitality and turned yellow', 'remove old and dusty wooden trinkets that tire the eyes'
    ],
    'Ateş': [
      'immediately replace blown bulbs and broken lighting', 'throw away melted, deformed old candles', 'remove aggressive objects with sharp and very sharp triangular forms',
      'remove broken electronic devices from the house', 'reduce excessively bright, eye-tiring red decors', 'replace thick and dark curtains completely blocking daylight',
      'remove paintings giving a feeling of aggression or danger', 'repair or throw away noisy broken appliances', 'organize tangled and dangerous extension cords',
      'remove old, worn and pilled synthetic rugs from the space', 'throw away old floor lamps radiating gloomy and dark energy', 'clean unnecessary clutter around the fireplace or stove'
    ],
    'Toprak': [
      'throw away cracked, broken ceramic or clay pots', 'repair unbalanced, wobbly tables and chairs', 'remove heavy trinkets collecting dust and not being used',
      'shrink unnecessarily large rugs or carpets narrowing the floor', 'thin out bulky furniture blocking the center and making passage difficult', 'remove broken marble or stone objects from the space',
      'throw away expired, dried makeup and earth-based products', 'reduce very dark brown or suffocating decors that weigh down the energy', 'repair walls or items with visible cracks',
      'fix unbalanced shelving systems with broken bottoms', 'reduce the decorative pillow piles more than you need', 'mobilize heavy items that have been in the same place for a long time creating stagnation'
    ],
    'Metal': [
      'remove rusted, oxidized metal items from the space', 'collect irregularly lying coin piles in a piggy bank', 'remove sharp-edged, threatening-looking metal objects',
      'throw away old keys and broken locks accumulated in drawers', 'send dead clocks and batteries to recycling', 'throw away unnecessary metal wire hangers and deformed kitchen tools',
      'reduce chrome surfaces making excessive reflection and tiring the eyes', 'organize tangled and knotted jewelry, broken necklaces', 'sort out unused, old cutlery sets',
      'tidy up old, rusty screws and toolbox clutter', 'destroy unnecessary bills and receipts kept in metal boxes', 'soften excessively metallic decorations feeling cold and distant'
    ],
    'Su': [
      'immediately repair leaking faucets and dripping pipes', 'clean vases or containers with stagnant, smelly water', 'replace cracked, stained or foggy mirrors with new ones',
      'throw away unnecessary cleaning supplies under the bathroom or sink', 'throw broken glass cups and chipped glassware in the trash', 'definitely unclog blocked sink and tub drains',
      'lighten excessively dark navy or black walls suffocating the energy', 'remove dark paintings giving a feeling of sadness or loneliness', 'throw away old, empty perfume and cosmetic bottles',
      'clarify dirty or stained glass on windows by wiping', 'clean damp, moldy corners and dry the moisture source', 'throw away expired, unused medicines and products in the bathroom'
    ],
  };

  static const gRemoves = {
    'Para': [
      'so open the physical blockages in front of the abundance energy.', 'and ensure the financial flow enters the space more comfortably.', 'so scatter the stagnant energy in your prosperity corner (southeast).',
      'and get rid of the negative energy triggering unnecessary expenses.', 'so break the mental and physical blockages preventing money entry.', 'and create space for opportunities to enter through your door more easily.',
      'so secure your earnings and block financial leaks.', 'and make room for new financial gains.', 'so clean the scarcity consciousness and strengthen the prosperity belief.',
      'and make the material return of your labor more visible.', 'so support continuous growth without financial stagnation.', 'and invite financial freedom to your life.'
    ],
    'Aşk': [
      'so clear the misunderstandings and communication blocks in your relationship.', 'and make room for your new partner to enter your life.', 'so balance the masculine-feminine (Yin-Yang) energy in your home.',
      'and destroy the emotional walls keeping love away.', 'so allow romance to flow freely into your life.', 'and get rid of the heavy energies of your past relationships.',
      'so strengthen your self-worth and self-love.', 'and remove the loneliness energy from your living spaces.', 'so add warmth and passion to your existing relationship.',
      'and repair the damaged trust bonds.', 'so increase the emotional intimacy between you and your partner.', 'and invite an unconditional love frequency.'
    ],
    'Kariyer': [
      'so remove the obstacles blocking your professional development.', 'and allow your talents to be noticed more easily.', 'so clarify the uncertainties in your career path.',
      'and open new doors for your promotion or job change.', 'so prevent the energy loss reducing your work efficiency.', 'and strengthen your reputation and prestige in your business environment.',
      'so establish more solid and supportive relationships with your colleagues.', 'and get rid of the fear of failure.', 'so increase your motivation to achieve your goals.',
      'and attract new business opportunities or customers.', 'so show your leadership qualities more clearly.', 'and discover your true potential in your career.'
    ],
    'Huzur': [
      'so destroy the hidden stress sources constantly occupying your mind.', 'and re-establish the spiritual balance in the center of the home (Tai Chi).', 'so evacuate the chaotic energy disturbing your inner calmness from the space.',
      'and experience a deeper tranquility during resting hours.', 'so prepare a soothing ground for family tensions and conflicts.', 'and create a simplicity that makes it easier to breathe in the living space.',
      'so leave the noise of the outside world at the door of your home.', 'and lighten up by getting rid of the visual pollution triggering anxiety.', 'so repair the energy leaks lowering your sleep quality.',
      'and create a pure space for your spiritual awakening or meditation.', 'so sweep away the dusty thoughts shadowing your mental clarity.', 'and provide a reassuring atmosphere of peace in every corner of your home.'
    ],
    'Sağlık': [
      'so remove the elements draining and tiring your physical energy from your life.', 'and create a clean vibration area supporting the physical healing process.', 'so accelerate the life energy (Chi) flow in the health corner (east).',
      'and scatter the stagnant, negative air weakening the immune system.', 'so allow the feeling of vitality and vigor to fill your home.', 'and throw away the environmental toxins causing chronic fatigue from the space.',
      'so provide a spacious sleep environment supporting cell renewal.', 'and erase the traces of unhealthy habits shadowing the joy of life.', 'so create spaces increasing your mental and physical flexibility.',
      'and keep the abundance and nutrition energy in your kitchen pure.', 'so make it easier for your body to adapt to its natural rhythm.', 'and heal the stagnant corners harboring disease energy by ventilating.'
    ],
  };

  static const elementPrefixes = {
    'Ağaç': 'With the growth power of Wood energy;',
    'Ateş': 'With the shining power of Fire element;',
    'Toprak': 'With the unshakable balance of Earth energy;',
    'Metal': 'With the clear and determined structure of Metal element;',
    'Su': 'With the deep fluidity of Water energy;',
  };

  static const tips = {
    'Para': [
      'Add a live plant to the Southeast corner; growing leaves attract prosperity.',
      'Keep the top left corner of your desk completely empty and organized for cash flow.',
      'Do not start the week without sparkling cleaning the kitchen stove representing prosperity.',
      'Put a golden yellow object next to the safe or wallet in the South corner.',
      'Remove items accumulated behind the entrance door to break material blockages.',
    ],
    'Aşk': [
      'Ensure bilateral harmony by definitely placing paired (double) objects in the Southwest corner.',
      'Leave equal space on both sides of your bed, this brings balance and justice to the relationship.',
      'Remove lonely (single) photos in the room and put smiling social frames instead.',
      'Trigger bringing closer and romantic energy by using dim lighting in warm tones.',
      'Throw away everything dried or feeling lifeless in your love corner and bring a new breath to that area.',
    ],
    'Kariyer': [
      'Accelerate opportunities by keeping wavy blue lines or a black detail in your North corner.',
      'Always sit at your desk facing the door, face obstacles head-on.',
      'Write your career goals clearly on a white paper this week and align it right to the center of your desk.',
      'Remove sharp-cornered and sharp-lined items on your desk away from your field of vision.',
      'On days you feel stuck in your business area, open your window and completely renew the air in the space.',
    ],
    'Huzur': [
      'Purify the center of your home (Tai Chi) from all obstacles suffocating energy and spend the week unblocked.',
      'Ground yourself by placing square formed natural objects from the earth group in the resting area.',
      'At least two days a week, sit silently in the exact center of the living room for 10 minutes and let go of all stress.',
      'Hang a serene painting with cloud or sea reflections that will empty your mind exactly opposite where you rest.',
      'Remove messy cables, excess technological devices or disorganized papers that tire the mind from sight.',
    ],
    'Sağlık': [
      'Awaken the blocked and accumulated bodily energy by adding a bright lively detail to the center of the home.',
      'The East facade symbolizes health; put an extra green fresh plant there specifically for this week.',
      'If your bedroom and bathroom doors face each other, always keep the bathroom door elegantly closed while sleeping this week.',
      'Relieve the immune energy by throwing away expired, long unused items and pills.',
      'Ensure the quality rest of cells by minimizing electronic devices in the sleep area.',
    ],
  };
}
