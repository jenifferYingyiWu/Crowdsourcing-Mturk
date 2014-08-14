package mturkcrowdsourcing;

import com.amazonaws.mturk.addon.HITQuestion;
import com.amazonaws.mturk.requester.Assignment;
import com.amazonaws.mturk.requester.AssignmentStatus;
import com.amazonaws.mturk.requester.Comparator;
import com.amazonaws.mturk.requester.GetAssignmentsForHITResult;
import com.amazonaws.mturk.requester.GetAssignmentsForHITSortProperty;
import com.amazonaws.mturk.requester.HIT;
import com.amazonaws.mturk.requester.Locale;
import com.amazonaws.mturk.requester.QualificationRequirement;
import com.amazonaws.mturk.requester.SortDirection;
import com.amazonaws.mturk.service.axis.RequesterService;
import com.amazonaws.mturk.util.PropertiesClientConfig;
import com.csvreader.CsvReader;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.SAXException;

class Question {
    String qID;
    String goldAnswer;
    String hitID;
    String qString;
}

class Answer {
    String identifier;
    String value;
    String workerID;
    String assignmentID;
    String status;
}


public class MTurkCrowdSourcing {

    private String title;
    private String description;
    private int numAssignments;
    private double rewardPerHitInDollars;
    private double fractionToFail;
    private ArrayList<Question> allQuestions;
    private List<List<Answer>> curResult;
    private long assignmentDurationInSeconds;
    private long autoApprovalDelayInSeconds;
    private long lifetimeInSeconds;
    private String keywords;
    private Map<String, String> choices;
    private RequesterService service;
    private String qFile;
    private boolean full;
    private boolean expire;
    private long checkInterval;
    private int minGoldAnswer;
    private String tmpFile = "./tmp/tmp.question";
    private FileWriter writer;
    private String crowdHistoryFile;
    
    void postAllQuestions() throws IOException, Exception{
        
        this.writer = new FileWriter(crowdHistoryFile,true);
        for(int i=0; i<allQuestions.size(); i++){
            Question q = allQuestions.get(i);
            PrintWriter writer = new PrintWriter(tmpFile, "UTF-8");
            writer.println(q.qString);
            writer.close();
            HITQuestion question = new HITQuestion("./" + tmpFile);
            HIT hit = service.createHIT(null,
                title, description, keywords, question.getQuestion(),
                rewardPerHitInDollars, assignmentDurationInSeconds,
                autoApprovalDelayInSeconds, lifetimeInSeconds,
                numAssignments, null, null, null
            );
            q.hitID = hit.getHITId();
            allQuestions.set(i, q);
            System.out.println("Question " + q.qID + " posted | numAssignments: " + numAssignments);
            this.writer.write("Question " + q.qID + " posted | numAssignments: " + numAssignments + "\n");
            if(i == allQuestions.size() - 1){
                System.out.println(service.getWebsiteURL() + "/mturk/preview?groupId=" + hit.getHITTypeId());
                this.writer.write(service.getWebsiteURL() + "/mturk/preview?groupId=" + hit.getHITTypeId() + "\n");
            }
            
        }
        this.writer.close();
        
    }
    
    void getAllAnswers() {
        
        full = true;
        expire = false;
        
        curResult = new ArrayList<List<Answer>>();
        
        for(int i=0; i<allQuestions.size();i++){
            List<Answer> curQuestionResult = new ArrayList<Answer>();
            Question q = allQuestions.get(i);
            HIT hit = service.getHIT(q.hitID);
            if("Reviewable".equals(hit.getHITStatus().getValue()) && hit.getNumberOfAssignmentsAvailable() > 0){
                expire = true;
            }
            GetAssignmentsForHITResult r = service.getAssignmentsForHIT(q.hitID, SortDirection.Ascending, null, GetAssignmentsForHITSortProperty.SubmitTime, null, null, null);
            AssignmentStatus[] rejStatus = new AssignmentStatus[] { AssignmentStatus.Rejected };
            GetAssignmentsForHITResult rRejected = service.getAssignmentsForHIT(q.hitID, SortDirection.Ascending, rejStatus, GetAssignmentsForHITSortProperty.SubmitTime, null, null, null);
            if(r.getNumResults() - rRejected.getNumResults() < numAssignments){
                full = false;
            }
            for(int j=0; j<r.getNumResults(); j++){
                Assignment ass = r.getAssignment(j);
                Answer ans = new Answer();
                ans.workerID = ass.getWorkerId();
                ans.assignmentID = ass.getAssignmentId();
                
                for(String k : choices.keySet()){
                    if(ass.getAnswer().contains("<SelectionIdentifier>" + k + "</SelectionIdentifier>")){
                        ans.identifier = k;
                        ans.value = choices.get(k);
                        break;
                    }
                }
                if("Rejected".equals(ass.getAssignmentStatus().toString())){
                    ans.status = "(r)";
                }else{
                    ans.status = "";
                }
                curQuestionResult.add(ans);
            }
            curResult.add(curQuestionResult);
        }
    }
    
    List<String> getBadWorkerIDs() {
        
        List<String> result = new ArrayList<String>();

        
        Map<String, Integer> workerID_CorrectNum_Map = new HashMap<String, Integer>();
        Map<String, Integer> workerID_WrongNum_Map = new HashMap<String, Integer>();
        
        boolean majority = true;
        
        for(int i=0; i<allQuestions.size(); i++){
            String goldAnswer = allQuestions.get(i).goldAnswer;
            if(!goldAnswer.isEmpty()){
                majority = false;
                for(int j=0; j<curResult.get(i).size(); j++){  
                    Answer ans = curResult.get(i).get(j);
                    if(ans.status.isEmpty()){
                        if(goldAnswer.equals(ans.value)){
                            if(workerID_CorrectNum_Map.containsKey(ans.workerID)){
                                int old = workerID_CorrectNum_Map.remove(ans.workerID);
                                workerID_CorrectNum_Map.put(ans.workerID, old+1);
                            }else{
                                workerID_CorrectNum_Map.put(ans.workerID, 1);
                            }
                            if(!workerID_WrongNum_Map.containsKey(ans.workerID)){
                                workerID_WrongNum_Map.put(ans.workerID, 0);
                            }
                        }else{
                            if(workerID_WrongNum_Map.containsKey(ans.workerID)){
                                int old = workerID_WrongNum_Map.remove(ans.workerID);
                                workerID_WrongNum_Map.put(ans.workerID, old+1);
                            }else{
                                workerID_WrongNum_Map.put(ans.workerID, 1);
                            }
                            if(!workerID_CorrectNum_Map.containsKey(ans.workerID)){
                                workerID_CorrectNum_Map.put(ans.workerID, 0);
                            }
                        }
                        
                    }
                }
            }
        }
        
        if(majority){
            for(int i=0; i<allQuestions.size(); i++){
                Map<String, Integer> choice_Count_Map = new HashMap<String, Integer>();
                for(String k : choices.keySet()){
                    choice_Count_Map.put(choices.get(k), 0);
                }
                for(int j=0; j<curResult.get(i).size();j++){
                    Answer ans = curResult.get(i).get(j);
                    if(ans.status.isEmpty()){
                        int old = choice_Count_Map.remove(ans.value);
                        choice_Count_Map.put(ans.value,old+1);
                    }
                }
                int maxCnt = 0;
                String goldAnswer = "";
                for(String k : choices.keySet()){
                    if(choice_Count_Map.get(choices.get(k)) > maxCnt){
                        maxCnt = choice_Count_Map.get(choices.get(k));
                        goldAnswer = choices.get(k);
                    }
                }
                
                for(int j=0; j<curResult.get(i).size(); j++){  
                    Answer ans = curResult.get(i).get(j);
                    if(ans.status.isEmpty()){
                        if(goldAnswer.equals(ans.value)){
                            if(workerID_CorrectNum_Map.containsKey(ans.workerID)){
                                int old = workerID_CorrectNum_Map.remove(ans.workerID);
                                workerID_CorrectNum_Map.put(ans.workerID, old+1);
                            }else{
                                workerID_CorrectNum_Map.put(ans.workerID, 1);
                            }
                            if(!workerID_WrongNum_Map.containsKey(ans.workerID)){
                                workerID_WrongNum_Map.put(ans.workerID, 0);
                            }
                        }else{
                            if(workerID_WrongNum_Map.containsKey(ans.workerID)){
                                int old = workerID_WrongNum_Map.remove(ans.workerID);
                                workerID_WrongNum_Map.put(ans.workerID, old+1);
                            }else{
                                workerID_WrongNum_Map.put(ans.workerID, 1);
                            }
                            if(!workerID_CorrectNum_Map.containsKey(ans.workerID)){
                                workerID_CorrectNum_Map.put(ans.workerID, 0);
                            }
                        }
                        
                    }
                }
            
            }
        }
        
        
        
        if(majority){
            for(String key : workerID_CorrectNum_Map.keySet()){
                double ratio = ((double)workerID_CorrectNum_Map.get(key))/((double) workerID_CorrectNum_Map.get(key) + (double) workerID_WrongNum_Map.get(key));
                if(ratio < fractionToFail){
                    result.add(key);
                }
            }
        }else{
            HashSet<String> allWorkers = new HashSet<String>();
            for(int i=0; i<allQuestions.size(); i++){
                for(int j=0; j<curResult.get(i).size(); j++){
                    if(curResult.get(i).get(j).status.isEmpty()){
                        allWorkers.add(curResult.get(i).get(j).workerID);
                    }
                }
            }
            for(String key : allWorkers){
                double ratio = ((double)workerID_CorrectNum_Map.get(key))/((double) workerID_CorrectNum_Map.get(key) + (int) workerID_WrongNum_Map.get(key));
                if(ratio < fractionToFail || (!workerID_CorrectNum_Map.containsKey(key)&&
                        !workerID_WrongNum_Map.containsKey(key)) || (!workerID_CorrectNum_Map.containsKey(key)&&
                        workerID_WrongNum_Map.get(key)<minGoldAnswer) ||
                        (!workerID_WrongNum_Map.containsKey(key) &&workerID_CorrectNum_Map.get(key)<minGoldAnswer)
                        || (workerID_WrongNum_Map.get(key)+workerID_CorrectNum_Map.get(key)<minGoldAnswer)){
                    result.add(key);
                }
            }
        }
        


        
        
        
        
        return result;
    }
    
    public void printStatus() throws IOException {
        
        for(int i=0; i<allQuestions.size();i++){
            Question q = allQuestions.get(i);
            if(!q.goldAnswer.isEmpty()){
                System.out.print("Q" + q.qID + "(g)" + " Result: ");
                writer.write("Q" + q.qID + "(g)" + " Result: ");
            }else{
                System.out.print("Q" + q.qID + " Result: ");
                writer.write("Q" + q.qID + " Result: ");
            }
            for(int j=0; j<curResult.get(i).size(); j++){
                System.out.print(curResult.get(i).get(j).identifier + curResult.get(i).get(j).status +  " ");
                writer.write(curResult.get(i).get(j).identifier + curResult.get(i).get(j).status +  " ");
            }
            System.out.println();
            writer.write("\n");
        }

    }
    
    
    
    void run() throws IOException, InterruptedException, Exception {
        
        postAllQuestions();
        
        while(true){
            this.writer = new FileWriter(crowdHistoryFile,true);
            
            
            Thread.sleep(checkInterval);
            System.out.println();
            writer.write("\n");
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DATE, 1);
            System.out.println(cal.getTime());
            writer.write(cal.getTime().toString() + "\n");
            getAllAnswers();
            if(full){
                List<String> badWorkerIDs = getBadWorkerIDs();
                if(badWorkerIDs.isEmpty()){
                    printStatus();
                    System.out.println("Finish! Those assignments will be approved automatically in " + autoApprovalDelayInSeconds + " seconds after their submission time.");
                    writer.write("Finish! Those assignments will be approved automatically in " + autoApprovalDelayInSeconds + " seconds after their submission time.\n");
                    writer.close();
                    break;
                }else{
                    for(int i=0; i<allQuestions.size();i++){
                        HIT hit = service.getHIT(allQuestions.get(i).hitID);
                        for(int j =0; j<curResult.get(i).size(); j++){
                            if(curResult.get(i).get(j).status.isEmpty() && badWorkerIDs.contains(curResult.get(i).get(j).workerID)){
                                String assID = curResult.get(i).get(j).assignmentID;
                                AssignmentStatus[] assStatus = new AssignmentStatus[] { AssignmentStatus.Rejected };
                                GetAssignmentsForHITResult curRejected = service.getAssignmentsForHIT(allQuestions.get(i).hitID, SortDirection.Ascending, assStatus, GetAssignmentsForHITSortProperty.SubmitTime, null, null, null);
                                service.rejectAssignment(assID,null);
                                service.extendHIT(allQuestions.get(i).hitID, numAssignments + curRejected.getNumResults() + 1, null);
                            } 
                        }
                    }
                    printStatus();
                }
            }else{
                printStatus();
            }
            
            if(expire){
                System.out.println("\nProgram terminates because HIT deadline has passed");
                writer.write("\nProgram terminates because HIT deadline has passed\n");
                writer.close();
                break;
            }
            
            writer.close();
            
        }
        
        
    }
    
    MTurkCrowdSourcing(String title, String description, int numAssignments,
            double rewardPerHitInDollars, double fractionToFail, 
            ArrayList<Question> allQuestions, long assignmentDurationInSeconds,
            long autoApprovalDelayInSeconds, long lifetimeInSeconds,
            String keywords, Map<String, String> choices, long checkInterval, 
            String qFile, String crowdHistoryFile, int minGoldAnswer) throws IOException{
        this.allQuestions = allQuestions;
        this.assignmentDurationInSeconds = assignmentDurationInSeconds;
        this.autoApprovalDelayInSeconds = autoApprovalDelayInSeconds;
        this.choices = choices;
        this.description = description;
        this.fractionToFail = fractionToFail;
        this.keywords = keywords;
        this.lifetimeInSeconds = lifetimeInSeconds;
        this.numAssignments = numAssignments;
        this.rewardPerHitInDollars = rewardPerHitInDollars;
        this.title = title;
        this.checkInterval = checkInterval;
        this.qFile = qFile;
        this.crowdHistoryFile = crowdHistoryFile;
        this.minGoldAnswer = minGoldAnswer;
        this.curResult = new ArrayList<List<Answer>>();
        this.service = new RequesterService(new PropertiesClientConfig());
    }

    static ArrayList<String> getList(String s){//seperated by commas, no space in between
        ArrayList<String> result = new ArrayList<>();
        if(s.isEmpty()){
            return result;
        }
        String[] array = s.split(",");
        for(int i=0; i<array.length; i++){
            result.add(array[i]);
        }
        return result;
    }
    

    public static void main(String[] args) throws IOException, Exception{

        
        
        String qFile = "../uploads/" + args[0];
        String dataFile = "../uploads/" + args[1];
        String title = args[2];
        String description = args[3];
        int numAssignments = Integer.parseInt(args[4]);//num of assignment per question/hit
        double rewardPerHitInDollars = Double.parseDouble(args[5]);
        double fractionToFail = Double.parseDouble(args[6]);//reject a worker if his accuracy is below "fractionToFail", apply to both majorityAnswer and goldAnswer strategy
        int minGoldAnswer = Integer.parseInt(args[7]);//reject a worker if he gives answers to less than "minGoldAnswer" gold questions; useless field (set to 0) if the stategy is majorityAnswer
        long assignmentDurationInSeconds  = Long.parseLong(args[8]);
        long autoApprovalDelayInSeconds = Long.parseLong(args[9]);
        long lifetimeInSeconds = Long.parseLong(args[10]);
        String keywords = args[11];
        long checkInterval = Long.parseLong(args[12]);//5 seconds
        String idCol = args[13];//id/primaryKey
        String goldCol = args[14];
        ArrayList<String> sqNums = getList(args[15]);
        ArrayList<String> gqNums = getList(args[16]);
        String crowdHistoryFile = "./history/" + args[17];
        
        
        
        
        /*******start of command line argument**************************************/
        /*******start of command line argument**************************************/
        /*******start of command line argument**************************************/
        /*
        String qFile = "../uploads/face10.question";
        String dataFile = "../uploads/face10.details";
        String title = "face orientation detection";
        String description = "determine the orientation of the face";
        int numAssignments = 1;//num of assignment per question/hit
        double rewardPerHitInDollars = 0.01;
        double fractionToFail = 0.4;//reject a worker if his accuracy is below "fractionToFail", apply to both majorityAnswer and goldAnswer strategy
        int minGoldAnswer = 0;//reject a worker if he gives answers to less than "minGoldAnswer" gold questions; useless field (set to 0) if the stategy is majorityAnswer
        long assignmentDurationInSeconds  = 5 * 60;
        long autoApprovalDelayInSeconds = 2 * 60 * 60;
        long lifetimeInSeconds = 60 * 60;
        String keywords = "face, orientation, picture, categorization, survey";
        long checkInterval = 5 * 1000;//5 seconds
        String idCol = "PrimaryKey";//id/primaryKey
        String goldCol = "orientation";
        ArrayList<String> sqNums = getList("2,3,4,5,6");
        ArrayList<String> gqNums = getList("3,6");
        String crowdHistoryFile = "./history/csHistory";
        */
        /*******end of command line argument***************************************/
        /*******end of command line argument***************************************/
        /*******end of command line argument***************************************/
        
        Map<String, String> choices = new HashMap<String, String>();
        

        FileWriter writer=new FileWriter(crowdHistoryFile);
        writer.close();
        
        
        String fileContent = new String(Files.readAllBytes(Paths.get(qFile)));
        int start = fileContent.indexOf("<Selections>");
        int end = fileContent.indexOf("</Selections>");
        String questionField = fileContent.substring(start, end);
        while(true){
            start = questionField.indexOf("<Text>");
            end = questionField.indexOf("</Text>");
            if(start == -1){
                break;
            }
            String choice = questionField.substring(start + 6, end);
            start = questionField.indexOf("<SelectionIdentifier>");
            end = questionField.indexOf("</SelectionIdentifier>");
            String identifier = questionField.substring(start + 21, end);
            questionField = questionField.replaceFirst("<SelectionIdentifier>.*?</SelectionIdentifier>", "");
            questionField = questionField.replaceFirst("<Text>.*?</Text>", "");
            
            choices.put(identifier, choice);

        }
        
        //get the data
        ArrayList<Question> allQuestions = new ArrayList<Question>();
        CsvReader record = new CsvReader(dataFile);
        record.readHeaders();
        while (record.readRecord()){
            String qID = record.get(idCol);
            if(sqNums.contains(qID)){
                Question q = new Question();
                q.qID = qID;

                String tmp = fileContent;
                while(true){
                    int i = tmp.indexOf("$");
                    int j = tmp.indexOf("}");
                    if(i != -1){
                        String colName = tmp.substring(i+2, j);
                        
                        tmp = tmp.replaceAll("\\$" + "\\{"+colName+"}", record.get(colName));
                    }else{
                        break;
                    }
                }
                q.qString = tmp;

                if(gqNums.contains(qID)){
                    q.goldAnswer = record.get(goldCol);
                }else{
                    q.goldAnswer = "";
                }
                allQuestions.add(q);
            }
        }
        
        MTurkCrowdSourcing cs = new MTurkCrowdSourcing(title, description, numAssignments,
            rewardPerHitInDollars, fractionToFail, 
            allQuestions, assignmentDurationInSeconds,
            autoApprovalDelayInSeconds, lifetimeInSeconds,
            keywords, choices, checkInterval, qFile,crowdHistoryFile, minGoldAnswer);
        
        cs.run();
        
    }
    
    
    
    
}
