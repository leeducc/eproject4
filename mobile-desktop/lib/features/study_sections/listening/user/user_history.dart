class UserHistory {

  static Set<int> wrongQuestions = {};

  static Set<int> correctQuestions = {};

  static void markWrong(int id) {
    wrongQuestions.add(id);
  }

  static void markCorrect(int id) {
    correctQuestions.add(id);
  }

}