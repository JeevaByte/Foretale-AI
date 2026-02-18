//core
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//models
import 'package:foretale_application/models/project_details_model.dart';
import 'package:foretale_application/models/user_details_model.dart';
import 'package:foretale_application/models/topic_list_model.dart';
//utils
import 'package:foretale_application/core/services/database/handling_crud.dart';

class Question {
  String questionText;  
  String industry;
  String projectType;
  String topic;
  String status;        
  String createdDate; 
  String createdBy;     
  String lastUpdatedBy;  
  String lastUpdatedDate; 
  int questionId;    
  bool isSelected;

  Question({
    this.questionText ='',
    this.industry = '',
    this.projectType = '',
    this.topic = '',
    this.status = 'A',
    this.createdDate = '',
    this.createdBy = '',
    this.lastUpdatedBy = '',
    this.lastUpdatedDate = '',
    this.questionId = 0,
    this.isSelected = false
  });

  // A method to convert a map back into a model object (e.g., when fetching data from Firestore).
  factory Question.fromJson(Map<String, dynamic> map) {
    return Question(
      questionText: map['question_text']??'',
      industry: map['industry']??'',
      projectType: map['project_type']??'',
      topic: map['topic']??'',
      status: map['status']?? 'A',
      createdDate: map['created_date']??'',
      createdBy: map['created_by']??'',
      lastUpdatedBy: map['last_updated_by']??'',
      lastUpdatedDate: map['last_updated_date']??'',
      questionId: map['question_id']??0,
      isSelected: bool.tryParse(map['is_selected'])??false,
    );
  }
}

class QuestionsModel with ChangeNotifier {
  final CRUD _crudService = CRUD();
  List<Question> questionsList = [];
  List<Question> get getQuestionsList => questionsList;

  bool _isPageLoading = false;
  bool get getIsPageLoading => _isPageLoading;
  set setIsPageLoading(bool value) {
    _isPageLoading = value;
    notifyListeners();
  }

  bool _isSaving = false;
  bool get getIsSaving => _isSaving;
  set setIsSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  List<String> _topicsList = [];
  List<String> get getTopicsList => _topicsList;
  void setTopicsList(List<String> value) {
    _topicsList = value;
    notifyListeners();
  }

  String _selectedTopic = '';
  String get getSelectedTopic => _selectedTopic;
  void setSelectedTopic(String value) {
    _selectedTopic = value;
    notifyListeners();
  }

  Future<void> fetchQuestionsByProject(BuildContext context) async {
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId
    };

    questionsList = await _crudService.getRecords<Question>(
      context,
      'dbo.sproc_get_questions_by_project_id',
      params,
      (json) => Question.fromJson(json),
    );  

    notifyListeners();
  }

  Future<int> selectQuestion(BuildContext context, Question question) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    _updateQuestionListOffline(question.questionId, true);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_id': question.questionId,
      'created_by': userDetailsModel.getUserMachineId, 
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_question_project',
      params,
    );

    if(insertedId == 0){
      fetchQuestionsByProject(context);
      notifyListeners();
    }

    return insertedId;
  }

  Future<int> unselectQuestion(BuildContext context, Question question) async {
    _updateQuestionListOffline(question.questionId, false);

    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_id': question.questionId,
      'last_updated_by': userDetailsModel.getUserMachineId
    };

    int updatedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_delete_assigned_question',
      params,
    );

    fetchQuestionsByProject(context);
    notifyListeners();    

    return updatedId;
  }

  //add question offline
  Future<int> addNewQuestionByProjectId(BuildContext context, String questionText, String topic) async {
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);

    var params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_text': questionText,
      'created_by': userDetailsModel.getUserMachineId, 
      'industry': projectDetailsModel.getIndustry,
      'project_type': projectDetailsModel.getProjectType,
      'topic': topic
    };

    int insertedId = await _crudService.addRecord(
      context,
      'dbo.sproc_insert_new_question_by_project',
      params,
    );

    if(insertedId > 0){
      fetchQuestionsByProject(context);
      notifyListeners();
    }

    return insertedId;
  }

  Future<int> removeQuestion(BuildContext context, Question question) async{
    var userDetailsModel = Provider.of<UserDetailsModel>(context, listen: false);
    var projectDetailsModel = Provider.of<ProjectDetailsModel>(context, listen: false);
    _removeQuestionOffline(question.questionId);

    final params = {
      'project_id': projectDetailsModel.getActiveProjectId,
      'question_id': question.questionId,
      'last_updated_by': userDetailsModel.getUserMachineId,
      'action': 'delete'
    };

    int deletedId = await _crudService.updateRecord(
      context,
      'dbo.sproc_delete_assigned_question',
      params,
    );

    fetchQuestionsByProject(context);
    notifyListeners();

    return deletedId;
  }

  void _removeQuestionOffline(int questionId) {
    var index = questionsList.indexWhere((q) => q.questionId == questionId);
    if (index != -1) {
      questionsList.removeAt(index);
    }
    notifyListeners();
  }

  void _updateQuestionListOffline(int questionId, bool isSelected) {
    var index = questionsList.indexWhere((q) => q.questionId == questionId);
    if (index != -1) {
      questionsList[index].isSelected = isSelected;
    }
    notifyListeners();
  }

  Future<void> fetchTopics(BuildContext context) async {
    if (_topicsList.isNotEmpty) return;
    
    try {
      List<Topic> lkpList = await TopicList().fetchAllActiveTopics(context);
      setTopicsList(lkpList.map((obj) => obj.name).toList());
    } catch (e) {
      setTopicsList([]);
    }
  }
}
