import java.util.HashMap;
import java.util.Arrays;
import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;

class GetParams {
	public static void main(String[] args) {
		String title = args[0];
		String description = args[1];
		int numAssignments = Integer.parseInt(args[2]);
		double reward = Double.parseDouble(args[3]);
		double percentFailed = Double.parseDouble(args[4]);
		String uploadedFile = args[5];

		System.out.println("Title: " + title);
		System.out.println("Description: " + description);
		System.out.println("Number of assignments: " + numAssignments);
		System.out.println("Reward: " + reward);
		System.out.println("Percentage failed to reject user: " + percentFailed);
		System.out.println("Uploaded file: " + uploadedFile);

		// args[6] is a string containing all the tweet ids separated by commas
		String [] tweetIDs_string = args[6].split(",");
		int [] tweetIDs = new int[tweetIDs_string.length];
		for (int id = 0; id < tweetIDs.length; id++)
			tweetIDs[id] = Integer.parseInt(tweetIDs_string[id]);
		Arrays.sort(tweetIDs);

		// Get the sentiment and text for the tweets we selected
		// from the file we uploaded (tweetsX.details)
		// Key=id, value=sentiment/text
		HashMap<Integer, Integer> sentiment = new HashMap<Integer, Integer>(); 
		HashMap<Integer, String> text = new HashMap<Integer, String>();

		try {
			String pathToFile = "uploads/" + uploadedFile;
			File file = new File(pathToFile);
			Scanner scanner = new Scanner(file);

			int id = 1, id_iter = 0;
			String row, currText;
			String [] parts, parts_onlyText;
			while (scanner.hasNextLine()) {
				row = scanner.nextLine();
				// only store tweets we selected
				if (id == tweetIDs[id_iter]) {
					parts = row.split(",");	
					sentiment.put(id, Integer.parseInt(parts[1]));

					// get rid of first 2 elts (ID and sentiment). Only text remains.
					parts_onlyText = Arrays.copyOfRange(parts, 2, parts.length);
					// put text back together incase it had commas and was split.
					currText = parts_onlyText[0];
					for (int i = 1; i < parts_onlyText.length; i++)
						currText += "," + parts_onlyText[i];
					text.put(id, currText);

					if (id_iter == tweetIDs.length-1)
						break;
					else
						id_iter++;
				}
				id++;
			}
			scanner.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}

		System.out.println("Tweets selected:");
		for (int id: tweetIDs)
			System.out.println(id + "," + sentiment.get(id) + "," + text.get(id));
	}
}
