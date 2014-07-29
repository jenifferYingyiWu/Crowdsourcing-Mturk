package turkhit;

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
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.Document;
import org.w3c.dom.Node;




class Question {
    String tweet;
    String hitID;
}
    
class Answer {
    int value;
    String workerID;
    String assignmentID;
    String status = "";//"r" for rejected
}


public class TurkHIT {


    
    private RequesterService service;
    private String title = "Sentiment Analysis of Tweet";
    private String description = "decide if the content of the following tweet is positive or negative";
    private double reward = 0.01;
    private String keywords = "tweet, sentiment, survey";
    private long assignmentDurationInSeconds = 120;//2 mins to answer each question
    private long autoApprovalDelayInSeconds = 60 * 60 * 24 * 15;//automatically approve an answer, if not approve/reject within 15 days after submission
    private long lifetimeInSeconds = 60*60*24*15;//15 days for each question to appear on the Turk
    private String requesterAnnotation = "tweet100k#sentiment";
    private int numAssignments;
    private String xmlFilePath = "tweet.question";
    private double percentageToFail;
    
    private List<Question> allQuestions = new ArrayList<Question>();
    private List<Integer> questionNums;
    private List<List<Answer>> curResult = new ArrayList<List<Answer>>();
    
    public TurkHIT() {
        service = new RequesterService(new PropertiesClientConfig());
    }
    
    public TurkHIT(String tweetsfile, List<Integer> questionNums, int numAssignments, String title, String description, double reward, double percentageToFail) throws FileNotFoundException, IOException {
        service = new RequesterService(new PropertiesClientConfig());

        this.numAssignments = numAssignments;
        this.questionNums = questionNums;
        this.title = title;
        this.description = description;
        this.reward = reward;
        this.percentageToFail = percentageToFail;
        
        File file = new File("../uploads/" + tweetsfile);
        BufferedReader reader = new BufferedReader(new FileReader(file));
        String text;
        while((text = reader.readLine()) != null) {
            int count = 0;
            int pos = 0;
            for(int i=0; i<text.length(); i++){
                if(text.charAt(i) == ','){
                    count+=1;
                    if(count == 2){
                        pos+=1;
                        break;
                    }
                }
                pos+=1;
            }
            Question q = new Question();
            q.hitID = null;
            q.tweet = text.substring(pos);
            allQuestions.add(q);
        }

        for (int i=0; i<allQuestions.size(); i++) {
            List<Answer> e = new ArrayList<Answer>();
            curResult.add(e);
        }
        
    }
    
    
    
    public String postOneQuestion(String tweet) throws IOException {
        
        FileWriter writer=new FileWriter("tweetCrowdHistory",true);
        
        
        HIT hit = null;
        try {
            //modify the tweet content in the xml file
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
            Document doc = docBuilder.parse(xmlFilePath);
            Node Text = doc.getElementsByTagName("Text").item(0);
            Text.setTextContent(tweet);
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            DOMSource source = new DOMSource(doc);
            StreamResult result = new StreamResult(new File(xmlFilePath));
            transformer.transform(source, result);            
            
            // This is an example of creating a qualification.
            // This is a built-in qualification -- user must be based in the US
            QualificationRequirement qualReq = new QualificationRequirement();
            qualReq.setQualificationTypeId(RequesterService.LOCALE_QUALIFICATION_TYPE_ID);
            qualReq.setComparator(Comparator.EqualTo);
            Locale country = new Locale();
            country.setCountry("US");
            qualReq.setLocaleValue(country);
            // The create HIT method takes in an array of QualificationRequirements
            // since a HIT can have multiple qualifications.
            QualificationRequirement[] qualReqs = new QualificationRequirement[] { qualReq };

            //set the question (tweet, true/false radiobutton)
            HITQuestion question = new HITQuestion("./tweet.question");
            
            //create the hit
            hit = service.createHIT(null, // HITTypeId 
                title, 
                description, keywords, 
                question.getQuestion(),
                reward, assignmentDurationInSeconds,
                autoApprovalDelayInSeconds, lifetimeInSeconds,
                numAssignments, requesterAnnotation, 
                qualReqs,
                null // responseGroup
              );
            
            writer.write("Created HIT: " + hit.getHITId() + "\n");
            writer.write("Question: " + tweet + " | numAssignments: " + numAssignments + "\n");
            writer.write("HIT location: "+ service.getWebsiteURL() + "/mturk/preview?groupId=" + hit.getHITTypeId() + "\n\n");
            
            
            System.out.println("Created HIT: " + hit.getHITId());
            System.out.println("Question: " + tweet + " | numAssignments: " + numAssignments);
            System.out.println("HIT location: "+ service.getWebsiteURL() + "/mturk/preview?groupId=" + hit.getHITTypeId() + "\n");
            
        } catch (Exception e) {
            System.err.println(e.getLocalizedMessage());
        }
        writer.close();
        
        if(hit != null){
            return hit.getHITId();
        }else{
            return "";
        }

    }
    
    
    public void postAllQuestions() throws IOException {
        ListIterator litr = questionNums.listIterator();
        while(litr.hasNext()){
            int i = (int) litr.next() - 1;
            String hitID = postOneQuestion(allQuestions.get(i).tweet);
            Question q = new Question();
            q.tweet = allQuestions.get(i).tweet;
            q.hitID = hitID;
            allQuestions.set(i, q);
        }
    }
    
    public void printStatus() throws IOException {
        
        FileWriter writer=new FileWriter("tweetCrowdHistory",true);
        
        ListIterator litr = questionNums.listIterator();
        while(litr.hasNext()){
            int i = (int) litr.next() - 1;
            Question q = allQuestions.get(i);
            
            writer.write(Integer.toString(i+1) + ". hitID: " + q.hitID + " Answers: ");
            System.out.print(Integer.toString(i+1) + ". hitID: " + q.hitID + " Answers: ");
            for(int j=0; j<curResult.get(i).size(); j++){
                if (curResult.get(i).get(j).status == "Rejected"){
                    writer.write(Integer.toString(curResult.get(i).get(j).value) + "r" + " ");
                    System.out.print(Integer.toString(curResult.get(i).get(j).value) + "r" + " ");
                }else{
                    writer.write(Integer.toString(curResult.get(i).get(j).value) + " ");
                    System.out.print(Integer.toString(curResult.get(i).get(j).value) + " ");
                }
            }
            writer.write("\n");
            System.out.print("\n");
        }
        writer.close();
    }
    
    public List<String> getBadWorkerIDs() {
        List<String> result = new ArrayList<String>();
        
        Map<String, Double> workerID_CorrectNum_Map = new HashMap<String, Double>();
        Map<String, Double> workerID_WrongNum_Map = new HashMap<String, Double>();
        
        ListIterator litr = questionNums.listIterator();
        while(litr.hasNext()){
            int i = (int) litr.next() - 1;
            
            int countZero = 0;
            int countOne = 0;
            int groundTruth;
            
            
            for(int j=0; j<curResult.get(i).size(); j++){
                if(curResult.get(i).get(j).status != "Rejected"){
                    if(curResult.get(i).get(j).value == 1){
                        countOne += 1;
                    }else{
                        countZero += 1;
                    }
                }
            }
        
            if(countOne >= countZero){
                groundTruth = 1;
            }else{
                groundTruth = 0;
            }
            
            for(int j=0; j<curResult.get(i).size(); j++){
                if(curResult.get(i).get(j).status != "Rejected"){
                    if(curResult.get(i).get(j).value == groundTruth){
                        Object old = workerID_CorrectNum_Map.remove(curResult.get(i).get(j).workerID);
                        if (old == null){
                            workerID_CorrectNum_Map.put(curResult.get(i).get(j).workerID,(double)1);
                        }else{
                            workerID_CorrectNum_Map.put(curResult.get(i).get(j).workerID, (double)old + 1);
                        }
                        if(!workerID_WrongNum_Map.containsKey(curResult.get(i).get(j).workerID)){
                            workerID_WrongNum_Map.put(curResult.get(i).get(j).workerID, (double)0);
                        }
                    }else{
                        Object old = workerID_WrongNum_Map.remove(curResult.get(i).get(j).workerID);
                        if (old == null){
                            workerID_WrongNum_Map.put(curResult.get(i).get(j).workerID,(double)1);
                        }else{
                            workerID_WrongNum_Map.put(curResult.get(i).get(j).workerID, (double)old + 1);
                        }
                        if(!workerID_CorrectNum_Map.containsKey(curResult.get(i).get(j).workerID)){
                            workerID_CorrectNum_Map.put(curResult.get(i).get(j).workerID, (double)0);
                        }
                    }
                }
            }

        }
        for(Object key : workerID_CorrectNum_Map.keySet()){
            double ratio = ((double)workerID_CorrectNum_Map.get(key))/((double) workerID_CorrectNum_Map.get(key) + (double) workerID_WrongNum_Map.get(key));
            if(ratio < this.percentageToFail){
                result.add((String)key);
            }
        }
        return result;
    }
    
    
    
    public void run() throws InterruptedException, IOException {
        
        FileWriter writer = new FileWriter("tweetCrowdHistory",true);
        
        while(true) {
            boolean expire = false;
            boolean full = true;
            Thread.sleep(1000 * 5);//60 seconds
            
            writer.write("\n");
            System.out.print("\n");
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.DATE, 1);
            
            writer.write(cal.getTime().toString() + "\n");
            System.out.println(cal.getTime());
            ListIterator litr = questionNums.listIterator();
            //get all submitted assignments status (includeing "approved", "rejected", and "submitted but not taken action")
            while(litr.hasNext()){
                int i = (int) litr.next() - 1;
                Question q = allQuestions.get(i);
                curResult.set(i, new ArrayList<Answer>());
                HIT hit = service.getHIT(q.hitID);
                if(hit.getHITStatus().getValue() == "Reviewable" && hit.getNumberOfAssignmentsAvailable() > 0) {//hit expire with some assignments unanswered
                    expire = true;
                }
                List<Answer> curQuestionResult = new ArrayList<Answer>();
                GetAssignmentsForHITResult r = service.getAssignmentsForHIT(q.hitID, SortDirection.Ascending, null, GetAssignmentsForHITSortProperty.SubmitTime, null, null, null);
                AssignmentStatus[] assStatus = new AssignmentStatus[] { AssignmentStatus.Rejected };
                GetAssignmentsForHITResult rRejected = service.getAssignmentsForHIT(q.hitID, SortDirection.Ascending, assStatus, GetAssignmentsForHITSortProperty.SubmitTime, null, null, null);
                if(r.getNumResults()-rRejected.getNumResults() < this.numAssignments){
                    full = false;
                }
                for(int j=0; j<r.getNumResults(); j++){
                    Assignment ass = r.getAssignment(j);
                    Answer ans = new Answer();
                    ans.workerID = ass.getWorkerId();
                    ans.assignmentID = ass.getAssignmentId();
                    if(ass.getAnswer().contains("<SelectionIdentifier>positive</SelectionIdentifier>")){
                        ans.value = 1;
                    }else{
                        ans.value = 0;
                    }
                    ans.status = ass.getAssignmentStatus().toString();
                    curQuestionResult.add(ans);
                }
                curResult.set(i, curQuestionResult);
            }
            
            if(full){
                List<String> badWorkerIDs = getBadWorkerIDs();
                if(badWorkerIDs.size() == 0){//all the workers are good
                    writer.close();
                    printStatus();
                    writer = new FileWriter("tweetCrowdHistory",true);
                    writer.write("\nFinish! Those assignments will be approved automatically in " + autoApprovalDelayInSeconds + " seconds after their submission time.\n");
                    System.out.println("Finish! Those assignments will be approved automatically in " + autoApprovalDelayInSeconds + " seconds after their submission time.");
                    break;
                }else{//need to reject those answers, and create more assignments to fill in the aimed number
                    litr = questionNums.listIterator();
                    while(litr.hasNext()){
                        int i = (int) litr.next() - 1;
                        HIT hit = service.getHIT(allQuestions.get(i).hitID);
                        for(int j =0; j<curResult.get(i).size(); j++){
                            if(curResult.get(i).get(j).status != "Rejected" && badWorkerIDs.contains(curResult.get(i).get(j).workerID)){
                                String assID = curResult.get(i).get(j).assignmentID;
                                AssignmentStatus[] assStatus = new AssignmentStatus[] { AssignmentStatus.Rejected };
                                GetAssignmentsForHITResult curRejected = service.getAssignmentsForHIT(allQuestions.get(i).hitID, SortDirection.Ascending, assStatus, GetAssignmentsForHITSortProperty.SubmitTime, null, null, null);
                                service.rejectAssignment(assID,null);
                                service.extendHIT(allQuestions.get(i).hitID, numAssignments + curRejected.getNumResults() + 1, null);
                            } 
                        }
                    }
                    writer.close();
                    printStatus();
                    writer = new FileWriter("tweetCrowdHistory",true);
                }
            }else{//continue
                writer.close();
                printStatus();
                writer = new FileWriter("tweetCrowdHistory",true);
            }
            
            if(expire){
                writer.write("\nProgram terminates because HIT deadline has passed\n");
                System.out.println("\nProgram terminates because HIT deadline has passed");
                break;

            }
        }
        
        writer.close();
        return;

    }
    
    
    
    
    public static void main(String[] args) throws IOException, InterruptedException {
        
        String title = args[0];
        String description = args[1];
        int numAssignments = Integer.parseInt(args[2]);
        double reward = Double.parseDouble(args[3]);
        double percentFailed = Double.parseDouble(args[4]);
        String uploadFile = args[5];
        
        String[] questionNums = args[6].split(",");
        int[] l = new int[questionNums.length];
        for(int i=0; i<questionNums.length; i++){
            l[i] = Integer.parseInt(questionNums[i]);
        }
        Arrays.sort(l);
        
        List<Integer> qList = new ArrayList<Integer>();
        for(int i=0; i<l.length; i++){
            qList.add(l[i]);
        }
        
        
        FileWriter writer=new FileWriter("tweetCrowdHistory");
        writer.close();
        
        TurkHIT app = new TurkHIT(uploadFile,qList,numAssignments, title, description, reward, percentFailed);
        app.postAllQuestions();
        app.run();
    }
}
