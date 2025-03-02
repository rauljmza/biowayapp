import 'package:xml/xml.dart' as xml;

/// Procesa un SVG que contiene un bloque <style>
/// convirtiendo las reglas CSS en atributos inline y eliminando el bloque <style>.
String processSvg(String rawSvg) {
  // Parseamos el documento SVG.
  final document = xml.XmlDocument.parse(rawSvg);

  // Extraemos todos los elementos <style>.
  final styleElements = document.findAllElements('style');
  final Map<String, Map<String, String>> styleMap = {};

  if (styleElements.isNotEmpty) {
    for (var styleElement in styleElements) {
      final cssText = styleElement.text;
      // Separa las reglas; cada regla termina en "}"
      final rules = cssText.split('}').map((r) => r.trim()).where((r) => r.isNotEmpty);
      for (var rule in rules) {
        // Cada regla tiene la forma: ".cls-1 { property: value; ... }"
        final parts = rule.split('{');
        if (parts.length < 2) continue;
        final selectorsPart = parts[0].trim();
        final declarationsPart = parts[1].trim();
        // Separamos los selectores (pueden venir separados por comas)
        final selectors = selectorsPart.split(',').map((s) => s.trim()).toList();
        // Separamos las declaraciones en "propiedad: valor;"
        final declarations = declarationsPart.split(';').map((d) => d.trim()).where((d) => d.isNotEmpty);
        final Map<String, String> declMap = {};
        for (var decl in declarations) {
          final declParts = decl.split(':');
          if (declParts.length < 2) continue;
          final property = declParts[0].trim();
          String value = declParts[1].trim();
          // Si el valor termina en "px", se quita la unidad
          if (value.endsWith('px')) {
            value = value.replaceAll('px', '').trim();
          }
          declMap[property] = value;
        }
        // Para cada selector (ejemplo: ".cls-1")
        for (var sel in selectors) {
          if (sel.startsWith('.')) {
            final className = sel.substring(1);
            if (styleMap.containsKey(className)) {
              styleMap[className]!.addAll(declMap);
            } else {
              styleMap[className] = Map.from(declMap);
            }
          }
        }
      }
      // Eliminamos el bloque <style> del documento.
      styleElement.parent?.children.remove(styleElement);
    }
  }

  // Recorremos el árbol del SVG y aplicamos los estilos inline a los elementos que tengan atributo "class".
  void traverse(xml.XmlNode node) {
    if (node is xml.XmlElement) {
      final classAttr = node.getAttribute('class');
      if (classAttr != null) {
        final classNames = classAttr.split(RegExp(r'\s+')).map((e) => e.trim()).where((e) => e.isNotEmpty);
        for (var cls in classNames) {
          if (styleMap.containsKey(cls)) {
            final styles = styleMap[cls]!;
            styles.forEach((property, value) {
              node.setAttribute(property, value);
            });
          }
        }
      }
      node.children.forEach(traverse);
    }
  }

  traverse(document.rootElement);
  return document.toXmlString();
}
