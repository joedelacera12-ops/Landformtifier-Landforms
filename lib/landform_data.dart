class Landform {
  final String name;
  final String imagePath;
  final String description;

  Landform({
    required this.name,
    required this.imagePath,
    required this.description,
  });
}

List<Landform> getLandforms() {
  return [
    Landform(
      name: 'Volcano',
      imagePath: 'assets/images/Volcano.jpg',
      description: 'A rupture in the crust allowing hot lava and gases to escape.',
    ),
    Landform(
      name: 'Hills',
      imagePath: 'assets/images/Hills.jpg',
      description: 'Raised areas of land, smaller and less steep than mountains.',
    ),
    Landform(
      name: 'Island',
      imagePath: 'assets/images/Island.jpg',
      description: 'Piece of land surrounded by water.',
    ),
    Landform(
      name: 'Canyon',
      imagePath: 'assets/images/Canyon.jpg',
      description: 'Deep gorge, typically one with a river flowing through it.',
    ),
    Landform(
      name: 'Desert',
      imagePath: 'assets/images/Desert.jpg',
      description: 'Barren area with little precipitation and hostile living conditions.',
    ),
    Landform(
      name: 'Mountains',
      imagePath: 'assets/images/Mountains.jpg',
      description: 'Large elevated landforms formed by tectonic forces.',
    ),
    Landform(
      name: 'Plain',
      imagePath: 'assets/images/Plain.jpg',
      description: 'Wide, flat areas of land with little elevation.',
    ),
    Landform(
      name: 'Peninsula',
      imagePath: 'assets/images/Peninsula.jpg',
      description: 'Piece of land almost surrounded by water or projecting out into a body of water.',
    ),
    Landform(
      name: 'Cave',
      imagePath: 'assets/images/Cave.jpg',
      description: 'A natural void in the ground, specifically a space large enough for a human to enter.',
    ),
    Landform(
      name: 'Plateau',
      imagePath: 'assets/images/Plateau.jpg',
      description: 'Elevated flat landforms with steep sides.',
    ),
  ];
}