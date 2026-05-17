import '../models/curriculum_outline.dart';

class FakeCurriculumData {
  static final List<CurriculumOutline> data = [
    CurriculumOutline(
      id: 'C001',
      knowledgePoint: '二次函数',
      grade: '九年级',
      difficulty: '中等',
      requirement: '理解二次函数的图像和性质，能求解二次函数的最值问题',
      description: '掌握y=ax²+bx+c的图像特征，包括开口方向、对称轴、顶点坐标',
      relatedTopics: ['一元二次方程', '图像平移', '最值问题'],
    ),
    CurriculumOutline(
      id: 'C002',
      knowledgePoint: '三角形全等',
      grade: '八年级',
      difficulty: '中等',
      requirement: '掌握三角形全等的判定定理，能应用于证明',
      description: '掌握SSS、SAS、ASA、AAS、HL五种判定方法',
      relatedTopics: ['三角形性质', '平行四边形', '证明'],
    ),
    CurriculumOutline(
      id: 'C003',
      knowledgePoint: '圆的性质',
      grade: '九年级',
      difficulty: '中等',
      requirement: '理解圆的基本性质，掌握圆周角、圆心角的关系',
      description: '掌握圆的切线、弦、弧、圆周角定理等',
      relatedTopics: ['三角形', '四边形', '几何证明'],
    ),
    CurriculumOutline(
      id: 'C004',
      knowledgePoint: '一元一次方程',
      grade: '七年级',
      difficulty: '简单',
      requirement: '能解一元一次方程，会列方程解应用题',
      description: '掌握移项、合并同类项等基本技能',
      relatedTopics: ['代数式', '应用题', '不等式'],
    ),
    CurriculumOutline(
      id: 'C005',
      knowledgePoint: '因式分解',
      grade: '八年级',
      difficulty: '中等',
      requirement: '掌握提取公因式、公式法、十字相乘法',
      description: '能对二次三项式进行因式分解',
      relatedTopics: ['整式乘法', '分式', '解方程'],
    ),
    CurriculumOutline(
      id: 'C006',
      knowledgePoint: '勾股定理',
      grade: '八年级',
      difficulty: '简单',
      requirement: '掌握勾股定理及其逆定理的应用',
      description: '理解a²+b²=c²的几何意义和应用',
      relatedTopics: ['直角三角形', '距离', '平方根'],
    ),
    CurriculumOutline(
      id: 'C007',
      knowledgePoint: '相似三角形',
      grade: '九年级',
      difficulty: '中等',
      requirement: '掌握相似三角形的判定和性质',
      description: '理解相似比、面积比的关系',
      relatedTopics: ['全等三角形', '比例线段', '三角函数'],
    ),
    CurriculumOutline(
      id: 'C008',
      knowledgePoint: '一次函数',
      grade: '八年级',
      difficulty: '中等',
      requirement: '理解一次函数的图像和性质，掌握斜率和截距',
      description: '掌握y=kx+b的图像和性质',
      relatedTopics: ['二元一次方程组', '不等式', '图像'],
    ),
    CurriculumOutline(
      id: 'C009',
      knowledgePoint: '反比例函数',
      grade: '九年级',
      difficulty: '中等',
      requirement: '理解反比例函数的图像和性质',
      description: '掌握y=k/x的图像特征',
      relatedTopics: ['一次函数', '分式', '图像'],
    ),
    CurriculumOutline(
      id: 'C010',
      knowledgePoint: '锐角三角函数',
      grade: '九年级',
      difficulty: '中等',
      requirement: '掌握正弦、余弦、正切的定义和基本应用',
      description: '能解直角三角形',
      relatedTopics: ['直角三角形', '相似三角形', '测量'],
    ),
    CurriculumOutline(
      id: 'C011',
      knowledgePoint: '统计与概率',
      grade: '九年级',
      difficulty: '简单',
      requirement: '掌握统计图表和概率的基本计算',
      description: '理解平均数、中位数、众数、方差等',
      relatedTopics: ['数据收集', '统计图', '概率'],
    ),
    CurriculumOutline(
      id: 'C012',
      knowledgePoint: '平行四边形',
      grade: '八年级',
      difficulty: '中等',
      requirement: '掌握平行四边形的性质和判定',
      description: '理解对角线互相平分等性质',
      relatedTopics: ['三角形', '矩形', '菱形'],
    ),
  ];

  static List<CurriculumOutline> getAll() => data;

  static CurriculumOutline? getById(String id) {
    try {
      return data.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<CurriculumOutline> getByGrade(String grade) {
    return data.where((d) => d.grade == grade).toList();
  }

  static List<CurriculumOutline> getByKnowledgePoint(String knowledgePoint) {
    return data.where((d) => d.knowledgePoint == knowledgePoint).toList();
  }

  static String getCsvTemplate() {
    return '''ID,知识点,年级,难度,考纲要求,描述,相关主题
C001,二次函数,九年级,中等,理解二次函数的图像和性质，能求解二次函数的最值问题,掌握y=ax²+bx+c的图像特征，包括开口方向、对称轴、顶点坐标,一元二次方程;图像平移;最值问题
C002,三角形全等,八年级,中等,掌握三角形全等的判定定理，能应用于证明,掌握SSS、SAS、ASA、AAS、HL五种判定方法,三角形性质;平行四边形;证明''';
  }

  static List<CurriculumOutline> parseCsv(String csvContent) {
    final result = <CurriculumOutline>[];
    final lines = csvContent.split('\n');

    if (lines.length < 2) return result;

    final headers = lines[0].split(',');
    final headerIndex = <String, int>{};
    for (var i = 0; i < headers.length; i++) {
      headerIndex[headers[i].trim()] = i;
    }

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseCsvLine(line);
      final map = <String, String>{};

      headerIndex.forEach((header, index) {
        if (index < values.length) {
          map[header] = values[index].trim();
        }
      });

      if (map.containsKey('知识点') && map['知识点']!.isNotEmpty) {
        result.add(CurriculumOutline.fromMap(map));
      }
    }

    return result;
  }

  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }

    return result;
  }

  static String toCsv(List<CurriculumOutline> outlines) {
    final buffer = StringBuffer();
    buffer.writeln('ID,知识点,年级,难度,考纲要求,描述,相关主题');

    for (final outline in outlines) {
      buffer.writeln(
        '${outline.id},${outline.knowledgePoint},${outline.grade},${outline.difficulty},${outline.requirement},${outline.description},${outline.relatedTopics.join(';')}',
      );
    }

    return buffer.toString();
  }
}
