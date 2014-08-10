import java.util.HashMap;
import java.util.Arrays;
import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;

class GetParams {
	public static void main(String[] args) {
		String title = args[0];
		String description = args[1];
		int labelsPerRecord = Integer.parseInt(args[2]);
		double reward = Double.parseDouble(args[3]);
		int HITduration = Integer.parseInt(args[4]);
		Boolean usingGold = args[5].equals("true");
		double rejectionThreshold = Double.parseDouble(args[6]);
		double percentOfGold = 0;
		String labelCol = "";
		if (usingGold) {
			percentOfGold = Double.parseDouble(args[7]);	
			labelCol = args[8];
		}

		System.out.println("Title: " + title);
		System.out.println("Description: " + description);
		System.out.println("Labels per record: " + labelsPerRecord);
		System.out.println("Reward: " + reward);
		System.out.println("Duration of HIT: " + HITduration);
		System.out.println("Using gold: " + usingGold);
		System.out.println("Percentage failed to reject user: " + rejectionThreshold);
		if (usingGold) {
			System.out.println("Percent of gold chosen: " + percentOfGold);
			System.out.println("Name of column of labels: " + labelCol);
		}
		else {
			System.out.println("Percent of gold chosen: Not Applicable");
			System.out.println("Name of column of labels: Not Applicable");
		}

		String [] labelValues = args[9].split(",");
		System.out.print("Possible label values: ");
		for (String labelVal: labelValues) 
			System.out.print(labelVal + " ");
		System.out.println();

		String [] keys_of_selected_string = args[10].split(",");
		int [] keys_of_selected = new int[keys_of_selected_string.length];
		for (int key = 0; key < keys_of_selected.length; key++)
			keys_of_selected[key] = Integer.parseInt(keys_of_selected_string[key]);
		Arrays.sort(keys_of_selected);

		System.out.print("Keys of selected records: ");
		for (int key: keys_of_selected)
			System.out.print(key + " ");
		System.out.println();

		if (usingGold) {
			String [] keys_of_gold_string = args[11].split(",");
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

		String uploadedFile = args[12];
		System.out.println("Uploaded file: " + uploadedFile);

		// read upload file, and display content of records we chose.

	}
}
