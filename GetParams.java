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
		int minBatchSize = Integer.parseInt(args[4]);
		int HITduration = Integer.parseInt(args[5]);
		int contentCol = Integer.parseInt(args[6]);
		Boolean usingGold = args[7].equals("true");
		double rejectionThreshold = Double.parseDouble(args[8]);
		double percentOfGold = 0;
		if (usingGold)
			percentOfGold = Double.parseDouble(args[9]);	
		int labelCol = Integer.parseInt(args[10]);

		System.out.println("Title: " + title);
		System.out.println("Description: " + description);
		System.out.println("Number of assignments: " + numAssignments);
		System.out.println("Reward: " + reward);
		System.out.println("Minimum batch size: " + minBatchSize);
		System.out.println("Duration of HIT: " + HITduration);
		System.out.println("Column of content: " + contentCol);
		System.out.println("Using gold: " + usingGold);
		System.out.println("Percentage failed to reject user: " + rejectionThreshold);
		if (usingGold)
			System.out.println("Percent of gold chosen: " + percentOfGold);
		else
			System.out.println("Percent of gold chosen: Not Applicable");
		System.out.println("Column of labels: " + labelCol);

		// args[9] is a string containing all the keys of selected records separated by commas
		String [] keys_of_selected_string = args[11].split(",");
		int [] keys_of_selected = new int[keys_of_selected_string.length];
		for (int key = 0; key < keys_of_selected.length; key++)
			keys_of_selected[key] = Integer.parseInt(keys_of_selected_string[key]);
		Arrays.sort(keys_of_selected);

		System.out.print("Keys of selected records: ");
		for (int key: keys_of_selected)
			System.out.print(key + " ");
		System.out.println();

		if (usingGold) {
			// args[10] is a string containing all keys of records used as gold data separated by commas
			String [] keys_of_gold_string = args[12].split(",");
			int [] keys_of_gold = new int[keys_of_gold_string.length];
			for (int key = 0; key < keys_of_gold.length; key++)
				keys_of_gold[key] = Integer.parseInt(keys_of_gold_string[key]);
			Arrays.sort(keys_of_gold);

			System.out.print("Keys of records used as gold data: ");
			for (int key: keys_of_gold)
				System.out.print(key + " ");
			System.out.println();
		}
		else 
			System.out.println("Keys of records used as gold data: Not Applicable");

		String uploadedFile = args[13];
		System.out.println("Uploaded file: " + uploadedFile);
	}
}
