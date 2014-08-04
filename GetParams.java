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
		double rejectionThreshold = Double.parseDouble(args[4]);
		String uploadedFile = args[5];

		System.out.println("Title: " + title);
		System.out.println("Description: " + description);
		System.out.println("Number of assignments: " + numAssignments);
		System.out.println("Reward: " + reward);
		System.out.println("Percentage failed to reject user: " + rejectionThreshold);
		System.out.println("Uploaded file: " + uploadedFile);

		// args[6] is a string containing all the tweet ids separated by commas
		String [] keys_of_selected_string = args[6].split(",");
		int [] keys_of_selected = new int[keys_of_selected_string.length];
		for (int id = 0; id < keys_of_selected.length; id++)
			keys_of_selected[id] = Integer.parseInt(keys_of_selected_string[id]);
		Arrays.sort(keys_of_selected);

		System.out.print("Keys of selected records: ");
		for (int key: keys_of_selected)
			System.out.print(key + " ");
		System.out.println();

		int minBatchSize = Integer.parseInt(args[7]);
		int HITduration = Integer.parseInt(args[8]);
		Boolean labelsAvailable = args[9].equals("labels");

		System.out.println("Minimum batch size: " + minBatchSize);
		System.out.println("Duration of HIT: " + HITduration);
		System.out.println("Labels available: " + labelsAvailable);
	}
}
