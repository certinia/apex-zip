/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Demonstrates how to use the <c:unzipfile> component
 **/
public with sharing class UnzipDemoController 
{
	// Unzipped component state, in this case the Id of the ZipFile__c record
	public String unzippedState {get;set;}
	
	public UnzipDemoController()
	{
		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 
			'Unzip processing will start once the file is selected, please wait to be redirected to the results after this.'));
	}
	
	// Action Function method called by client code once all entries have been unzipped
	public PageReference unzipped()
	{
		// Redirect to ZipFile record
		return new PageReference('/' + unzippedState);	
	}
		
	@RemoteAction
	// JavaScript Remoting method called as each item is unzipped from the file
	public static String receiveZipFileEntry(String filename, String path, String data, String state)
	{
		// First file?
		if(state=='')
		{
			// Create a record to store unzipped files as attachments
			ZipFile__c zipFile = new ZipFile__c();
			zipFile.Name = filename;
			insert zipFile;
			state = zipFile.Id;
		}
		
		// Attach unzipped file
		Attachment attachment = new Attachment();
		attachment.Body = EncodingUtil.base64Decode(data);
		attachment.Name = path;
		attachment.ParentId = state;
		insert attachment;
		
		return state;		
	}	
}