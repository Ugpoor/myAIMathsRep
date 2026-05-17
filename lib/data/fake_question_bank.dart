import 'dart:math';

final Random _random = Random(42);

final List<String> _knowledgePoints = [
  '二次函数',
  '三角形全等',
  '圆的性质',
  '相似三角形',
  '实数运算',
  '一元二次方程',
  '反比例函数',
  '勾股定理',
  '三角函数',
  '概率统计',
  '整式运算',
  '分式运算',
  '根式运算',
  '一元一次方程',
  '二元一次方程组',
  '不等式',
  '因式分解',
  '图形变换',
  '坐标几何',
  '数列',
];

final List<String> _questionTypes = ['选择题', '填空题', '解答题', '证明题', '计算题'];

final List<String> _difficulties = ['简单', '中等', '困难'];

List<Map<String, dynamic>> generateQuestionBank() {
  final questions = <Map<String, dynamic>>[];

  for (int i = 1; i <= 100; i++) {
    final knowledgePoint =
        _knowledgePoints[_random.nextInt(_knowledgePoints.length)];
    final questionType = _questionTypes[_random.nextInt(_questionTypes.length)];
    final difficulty = _difficulties[_random.nextInt(_difficulties.length)];
    final hasError = _random.nextDouble() < 0.15;

    questions.add({
      'id': i.toString().padLeft(4, '0'),
      'questionId': 'Q${i.toString().padLeft(4, '0')}',
      'knowledgePoint': knowledgePoint,
      'questionType': questionType,
      'difficulty': difficulty,
      'content': _generateQuestionContent(knowledgePoint, questionType, i),
      'answer': _generateAnswer(knowledgePoint, questionType),
      'hasError': hasError,
      'errorNote': hasError ? '题目条件表述不清' : '',
      'createdAt': _generateDate(2026, 1, 5, i),
    });
  }

  return questions;
}

String _generateQuestionContent(
  String knowledgePoint,
  String questionType,
  int index,
) {
  switch (knowledgePoint) {
    case '二次函数':
      if (questionType == '选择题') {
        return '二次函数y=x²-4x+3的顶点坐标是：A) (2,-1) B) (-2,1) C) (2,1) D) (-2,-1)';
      } else if (questionType == '填空题') {
        return '二次函数y=x²-6x+5的对称轴是______。';
      } else if (questionType == '解答题') {
        return '已知二次函数y=ax²+bx+c经过点(1,0)、(2,3)、(0,-3)，求a、b、c的值。';
      } else {
        return '证明：二次函数y=x²-2x+2的图像恒在x轴上方。';
      }
    case '三角形全等':
      if (questionType == '选择题') {
        return '下列条件中，不能判定两个三角形全等的是：A) SSS B) SAS C) ASA D) SSA';
      } else if (questionType == '填空题') {
        return '在△ABC中，AB=AC，AD是中线，则△ABD≌______。';
      } else if (questionType == '解答题') {
        return '已知AB=DE，BC=EF，∠B=∠E，证明△ABC≌△DEF。';
      } else {
        return '证明：等腰三角形底边上的中线垂直于底边。';
      }
    case '圆的性质':
      if (questionType == '选择题') {
        return '圆的直径为10，则圆的周长是：A) 5π B) 10π C) 25π D) 50π';
      } else if (questionType == '填空题') {
        return '圆的半径为6，圆心角为60°的扇形面积是______。';
      } else if (questionType == '解答题') {
        return '已知圆的方程为x²+y²=25，求过点(3,4)的切线方程。';
      } else {
        return '证明：直径所对的圆周角是直角。';
      }
    case '相似三角形':
      if (questionType == '选择题') {
        return '相似三角形的面积比为4:9，则它们的相似比为：A) 2:3 B) 4:9 C) 16:81 D) √2:3';
      } else if (questionType == '填空题') {
        return '△ABC～△DEF，相似比为1:2，若BC=4，则EF=______。';
      } else if (questionType == '解答题') {
        return '在△ABC中，DE∥BC，AD=2，DB=3，AE=4，求EC的长。';
      } else {
        return '证明：平行于三角形一边的直线截其他两边，所得对应线段成比例。';
      }
    case '实数运算':
      if (questionType == '计算题') {
        return '计算：√18 - √8 + √2';
      } else if (questionType == '选择题') {
        return '√2 × √8 = ？A) √10 B) 4 C) 2√2 D) 8';
      } else {
        return '化简：(√3 + 1)(√3 - 1)';
      }
    case '一元二次方程':
      if (questionType == '选择题') {
        return '方程x²-5x+6=0的根是：A) x=2或x=3 B) x=-2或x=-3 C) x=1或x=6 D) x=-1或x=-6';
      } else if (questionType == '填空题') {
        return '方程x²-4=0的解是______。';
      } else {
        return '解方程：2x²-5x+2=0';
      }
    case '勾股定理':
      if (questionType == '选择题') {
        return '直角三角形两直角边分别为3和4，则斜边长为：A) 5 B) 6 C) 7 D) 25';
      } else if (questionType == '填空题') {
        return '直角三角形斜边为13，一直角边为5，则另一直角边为______。';
      } else {
        return '已知直角三角形的两直角边分别为5和12，求斜边上的高。';
      }
    default:
      return '题目${index}：关于${knowledgePoint}的${questionType}';
  }
}

String _generateAnswer(String knowledgePoint, String questionType) {
  switch (knowledgePoint) {
    case '二次函数':
      if (questionType == '选择题') return 'A';
      if (questionType == '填空题') return 'x=3';
      if (questionType == '解答题') return 'a=3, b=-6, c=-3';
      return '证明：y=(x-1)²+1≥1>0，故图像恒在x轴上方';
    case '三角形全等':
      if (questionType == '选择题') return 'D';
      if (questionType == '填空题') return '△ACD';
      return '证明：∵AB=DE，∠B=∠E，BC=EF，∴△ABC≌△DEF(SAS)';
    case '圆的性质':
      if (questionType == '选择题') return 'B';
      if (questionType == '填空题') return '6π';
      if (questionType == '解答题') return '3x+4y-25=0';
      return '证明：设直径AB，圆周角∠ACB，连接OC，则OA=OB=OC，∴∠OCA=∠OAC，∠OCB=∠OBC，∴∠ACB=90°';
    case '相似三角形':
      if (questionType == '选择题') return 'A';
      if (questionType == '填空题') return '8';
      if (questionType == '解答题') return 'EC=6';
      return '证明：由平行线性质可得对应角相等，故对应线段成比例';
    case '实数运算':
      if (questionType == '计算题') return '3√2';
      if (questionType == '选择题') return 'B';
      return '2';
    case '一元二次方程':
      if (questionType == '选择题') return 'A';
      if (questionType == '填空题') return 'x=±2';
      return 'x=2或x=1/2';
    case '勾股定理':
      if (questionType == '选择题') return 'A';
      if (questionType == '填空题') return '12';
      return '60/13';
    default:
      return '答案';
  }
}

String _generateDate(int year, int startMonth, int startDay, int offset) {
  final baseDate = DateTime(year, startMonth, startDay);
  final date = baseDate.add(Duration(days: offset));
  return '${date.year}/${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

final List<Map<String, dynamic>> questionBankData = generateQuestionBank();
